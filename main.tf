locals {
  enabled                                   = module.this.enabled
  ipv6_egress_only_internet_gateway_enabled = local.enabled && var.ipv6_egress_only_internet_gateway_enabled
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}

resource "aws_vpc" "default" {
  count = local.enabled ? 1 : 0

  #bridgecrew:skip=BC_AWS_LOGGING_9:VPC Flow Logs are meant to be enabled by terraform-aws-vpc-flow-logs-s3-bucket and/or terraform-aws-cloudwatch-flow-logs
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = local.dns_hostnames_enabled
  enable_dns_support               = local.dns_support_enabled
  enable_classiclink               = local.classiclink_enabled
  enable_classiclink_dns_support   = local.classiclink_dns_support_enabled
  assign_generated_ipv6_cidr_block = local.ipv6_enabled
  tags                             = module.label.tags
}

# If `aws_default_security_group` is not defined, it will be created implicitly with access `0.0.0.0/0`
resource "aws_default_security_group" "default" {
  count = local.default_security_group_deny_all ? 1 : 0

  vpc_id = aws_vpc.default[0].id
  tags   = merge(module.label.tags, { Name = "Default Security Group" })
}

resource "aws_internet_gateway" "default" {
  count = local.internet_gateway_enabled ? 1 : 0

  vpc_id = aws_vpc.default[0].id
  tags   = module.label.tags
}

resource "aws_egress_only_internet_gateway" "default" {
  count = local.ipv6_egress_only_internet_gateway_enabled ? 1 : 0

  vpc_id = aws_vpc.default[0].id
  tags   = module.label.tags
}
resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each = local.enabled ? toset(var.additional_cidr_blocks) : []

  vpc_id     = aws_vpc.default[0].id
  cidr_block = each.key
}
