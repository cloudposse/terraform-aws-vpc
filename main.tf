locals {
  enabled                                         = module.this.enabled
  enable_default_security_group_with_custom_rules = var.enable_default_security_group_with_custom_rules && local.enabled ? 1 : 0
  enable_internet_gateway                         = var.enable_internet_gateway && local.enabled ? 1 : 0
  additional_cidr_blocks_defined                  = local.enabled && var.additional_cidr_blocks != null ? true : false
  additional_cidr_blocks                          = local.additional_cidr_blocks_defined ? var.additional_cidr_blocks : []
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context = module.this.context
}

resource "aws_vpc" "default" {
  count                            = local.enabled ? 1 : 0
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  tags                             = module.label.tags
}

# If `aws_default_security_group` is not defined, it would be created implicitly with access `0.0.0.0/0`
resource "aws_default_security_group" "default" {
  count  = local.enable_default_security_group_with_custom_rules
  vpc_id = join("", aws_vpc.default.*.id)

  tags = merge(module.label.tags, { Name = "Default Security Group" })
}

resource "aws_internet_gateway" "default" {
  count  = local.enable_internet_gateway
  vpc_id = join("", aws_vpc.default.*.id)
  tags   = module.label.tags
}

resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each   = toset(local.additional_cidr_blocks)
  vpc_id     = join("", aws_vpc.default.*.id)
  cidr_block = each.key
}
