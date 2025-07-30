locals {
  enabled = module.this.enabled && (length(var.gateway_vpc_endpoints) + length(var.interface_vpc_endpoints) > 0)

  # Because route table ID may not be known at plan time, we cannot use it as a key
  route_table_associations_list = flatten([for k, v in var.gateway_vpc_endpoints : [
    for i, r in v.route_table_ids : {
      key            = "${k}[${i}]"
      gateway        = k
      route_table_id = r
    }
  ]])

  route_table_associations_map = { for v in local.route_table_associations_list : v.key => v }

  # Because subnet ID may not be known at plan time, we cannot use it as a key
  subnet_associations_list = flatten([for k, v in var.interface_vpc_endpoints : [
    for i, s in v.subnet_ids : {
      key       = "${k}[${i}]"
      interface = k
      subnet_id = s
    }
  ]])

  subnet_associations_map = { for v in local.subnet_associations_list : v.key => v }

  # Because security group ID may not be known at plan time, we cannot use it as a key
  security_group_associations_list = flatten([for k, v in var.interface_vpc_endpoints : [
    for i, s in v.security_group_ids : {
      key               = "${k}[${i}]"
      local_index       = i # Index within this VPC endpoint
      interface         = k
      security_group_id = s
    }
  ]])

  # Create a global index for serializing ALL security group operations
  security_group_associations_with_global_index = [
    for i, v in local.security_group_associations_list : merge(v, {
      global_index = i # Global index across ALL security group associations
    })
  ]

  security_group_associations_map = {
    for v in local.security_group_associations_with_global_index : v.key => v
  }
}

# Unfortunately, the AWS provider makes us jump through hoops to deal with the
# association of an endpoint interface with the default VPC security group.
# See https://github.com/hashicorp/terraform-provider-aws/issues/27100
data "aws_security_group" "default" {
  count = local.enabled ? 1 : 0

  filter {
    name   = "group-name"
    values = ["default"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_vpc_endpoint_service" "gateway_endpoint_service" {
  for_each     = local.enabled ? var.gateway_vpc_endpoints : {}
  service      = var.gateway_vpc_endpoints[each.key].name
  service_type = "Gateway"
}

data "aws_vpc_endpoint_service" "interface_endpoint_service" {
  for_each     = local.enabled ? var.interface_vpc_endpoints : {}
  service      = var.interface_vpc_endpoints[each.key].name
  service_type = "Interface"
}

module "gateway_endpoint_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each   = local.enabled ? data.aws_vpc_endpoint_service.gateway_endpoint_service : {}
  attributes = [each.key]

  context = module.this.context
}

module "interface_endpoint_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each   = local.enabled ? data.aws_vpc_endpoint_service.interface_endpoint_service : {}
  attributes = [each.key]

  context = module.this.context
}

resource "aws_vpc_endpoint" "gateway_endpoint" {
  for_each          = local.enabled ? data.aws_vpc_endpoint_service.gateway_endpoint_service : {}
  service_name      = data.aws_vpc_endpoint_service.gateway_endpoint_service[each.key].service_name
  policy            = var.gateway_vpc_endpoints[each.key].policy
  vpc_endpoint_type = data.aws_vpc_endpoint_service.gateway_endpoint_service[each.key].service_type
  vpc_id            = var.vpc_id

  tags = module.gateway_endpoint_label[each.key].tags
}

resource "aws_vpc_endpoint_route_table_association" "gateway" {
  for_each = local.enabled ? local.route_table_associations_map : {}

  route_table_id  = each.value.route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.gateway_endpoint[each.value.gateway].id
}

resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each            = local.enabled ? data.aws_vpc_endpoint_service.interface_endpoint_service : {}
  service_name        = data.aws_vpc_endpoint_service.interface_endpoint_service[each.key].service_name
  policy              = var.interface_vpc_endpoints[each.key].policy
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.interface_endpoint_service[each.key].service_type
  vpc_id              = var.vpc_id
  private_dns_enabled = var.interface_vpc_endpoints[each.key].private_dns_enabled

  tags = module.interface_endpoint_label[each.key].tags
}

# Give each VPC endpoint time to fully initialize before associations start
resource "time_sleep" "endpoint_settling" {
  for_each = local.enabled ? var.interface_vpc_endpoints : {}

  # Give AWS time to fully initialize the endpoint
  create_duration = "30s"

  # Wait for the endpoint to be created
  triggers = {
    endpoint_id = aws_vpc_endpoint.interface_endpoint[each.key].id
  }

  depends_on = [
    aws_vpc_endpoint.interface_endpoint
  ]
}

resource "aws_vpc_endpoint_subnet_association" "interface" {
  for_each = local.enabled ? local.subnet_associations_map : {}

  subnet_id = each.value.subnet_id
  # Read the endpoint ID through the settling delay to ensure proper timing
  vpc_endpoint_id = time_sleep.endpoint_settling[each.value.interface].triggers["endpoint_id"]
}

# Create time delays to serialize ALL security group operations globally
# This prevents ANY concurrent VPC endpoint modifications
resource "time_sleep" "security_group_delay" {
  for_each = local.enabled ? local.security_group_associations_map : {}

  # Serialize ALL security group operations globally: 0s, 15s, 30s, 45s, etc.
  # This ensures no two security group associations happen simultaneously
  create_duration = "${each.value.global_index * 15}s"

  # Use triggers to pass through the association data and create proper dependencies
  triggers = {
    security_group_id = each.value.security_group_id
    vpc_endpoint_id   = time_sleep.endpoint_settling[each.value.interface].triggers["endpoint_id"]
    interface         = each.value.interface
    global_index      = each.value.global_index
  }

  depends_on = [
    aws_vpc_endpoint_subnet_association.interface,
    time_sleep.endpoint_settling
  ]
}

resource "aws_vpc_endpoint_security_group_association" "interface" {
  for_each = local.enabled ? local.security_group_associations_map : {}

  # It is an error to replace the default association with the default security group
  # See https://github.com/hashicorp/terraform-provider-aws/issues/27100
  # Use local_index (index within the VPC endpoint) for this logic
  replace_default_association = each.value.local_index == 0 && each.value.security_group_id != data.aws_security_group.default[0].id

  # Read the values "through" the time_sleep resource to ensure proper dependency and delay
  security_group_id = time_sleep.security_group_delay[each.key].triggers["security_group_id"]
  vpc_endpoint_id   = time_sleep.security_group_delay[each.key].triggers["vpc_endpoint_id"]

  lifecycle {
    create_before_destroy = true
  }
}
