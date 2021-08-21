locals {
  enabled = module.this.enabled && (length(var.gateway_vpc_endpoints) > 0 || length(var.interface_vpc_endpoints) > 0)
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

resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each            = local.enabled ? data.aws_vpc_endpoint_service.interface_endpoint_service : {}
  service_name        = data.aws_vpc_endpoint_service.interface_endpoint_service[each.key].service_name
  policy              = var.interface_vpc_endpoints[each.key].policy
  security_group_ids  = var.interface_vpc_endpoints[each.key].security_group_ids
  subnet_ids          = var.interface_vpc_endpoints[each.key].subnet_ids
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.interface_endpoint_service[each.key].service_type
  vpc_id              = var.vpc_id
  private_dns_enabled = var.interface_vpc_endpoints[each.key].private_dns_enabled

  tags = module.interface_endpoint_label[each.key].tags
}