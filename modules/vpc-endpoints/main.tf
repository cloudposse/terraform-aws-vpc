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
      index             = i
      interface         = k
      security_group_id = s
    }
  ]])

  security_group_associations_map = { for v in local.security_group_associations_list : v.key => v }
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

resource "aws_vpc_endpoint_subnet_association" "interface" {
  for_each = local.enabled ? local.subnet_associations_map : {}

  subnet_id       = each.value.subnet_id
  vpc_endpoint_id = aws_vpc_endpoint.interface_endpoint[each.value.interface].id
}

resource "aws_vpc_endpoint_security_group_association" "interface" {
  for_each = local.enabled ? local.security_group_associations_map : {}

  # It is an error to replace the default association with the default security group
  # See https://github.com/hashicorp/terraform-provider-aws/issues/27100
  replace_default_association = each.value.index == 0 && each.value.security_group_id != data.aws_security_group.default[0].id

  security_group_id = each.value.security_group_id
  vpc_endpoint_id   = aws_vpc_endpoint.interface_endpoint[each.value.interface].id

  depends_on = [aws_vpc_endpoint_subnet_association.interface]
}
