locals {
  enabled = var.context.enabled && (length(var.gateway_vpc_endpoints) > 0 || length(var.interface_vpc_endpoints) > 0)
}

data "aws_vpc" "vpc" {
  count = local.enabled ? 1 : 0
  id    = var.vpc_id
}

data "aws_vpc_endpoint_service" "gateway_endpoint_service" {
  for_each     = var.gateway_vpc_endpoints
  service      = var.gateway_vpc_endpoints[each.key].name
  service_type = "Gateway"
}

data "aws_vpc_endpoint_service" "interface_endpoint_service" {
  for_each     = var.interface_vpc_endpoints
  service      = var.interface_vpc_endpoints[each.key].name
  service_type = "Interface"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context = module.this.context
}

resource "aws_vpc_endpoint" "gateway_endpoint" {
  for_each          = data.aws_vpc_endpoint_service.gateway_endpoint_service
  service_name      = data.aws_vpc_endpoint_service.gateway_endpoint_service[each.key].service_name
  policy            = var.gateway_vpc_endpoints[each.key].policy
  vpc_endpoint_type = data.aws_vpc_endpoint_service.gateway_endpoint_service[each.key].service_type
  vpc_id            = data.aws_vpc.vpc[0].id
  tags              = module.label.tags
}

resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each           = data.aws_vpc_endpoint_service.interface_endpoint_service
  service_name       = data.aws_vpc_endpoint_service.interface_endpoint_service[each.key].service_name
  policy             = var.interface_vpc_endpoints[each.key].policy
  security_group_ids = var.interface_vpc_endpoints[each.key].security_group_ids
  subnet_ids         = var.interface_vpc_endpoints[each.key].subnet_ids
  vpc_endpoint_type  = data.aws_vpc_endpoint_service.interface_endpoint_service[each.key].service_type
  vpc_id             = data.aws_vpc.vpc[0].id
  tags               = module.label.tags
}