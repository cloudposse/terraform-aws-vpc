locals {
  enable_default_security_group_with_custom_rules = var.enable_default_security_group_with_custom_rules && var.enabled ? 1 : 0
  enable_internet_gateway                         = var.enable_internet_gateway && var.enabled ? 1 : 0
}


module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.0"
  namespace   = var.namespace
  name        = var.name
  stage       = var.stage
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
  enabled     = var.enabled
}

resource "aws_vpc" "default" {
  count                            = var.enabled ? 1 : 0
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = true
  tags                             = module.label.tags
}

# If `aws_default_security_group` is not defined, it would be created implicitly with access `0.0.0.0/0`
resource "aws_default_security_group" "default" {
  count  = local.enable_default_security_group_with_custom_rules
  vpc_id = join("", aws_vpc.default.*.id)

  tags = {
    Name = "Default Security Group"
  }
}

resource "aws_internet_gateway" "default" {
  count  = local.enable_internet_gateway
  vpc_id = join("", aws_vpc.default.*.id)
  tags   = module.label.tags
}
