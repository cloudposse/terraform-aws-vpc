locals {
  enabled                                         = module.this.enabled
  enable_default_security_group_with_custom_rules = var.enable_default_security_group_with_custom_rules && local.enabled ? 1 : 0
  enable_internet_gateway                         = var.enable_internet_gateway && local.enabled ? 1 : 0
  enable_egress_only_internet_gateway             = var.enable_egress_only_internet_gateway && local.enabled ? 1 : 0
  additional_cidr_blocks_defined                  = local.enabled && var.additional_cidr_blocks != null ? true : false
  additional_cidr_blocks                          = local.additional_cidr_blocks_defined ? var.additional_cidr_blocks : []
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}

resource "aws_vpc" "default" {
  count = local.enabled ? 1 : 0
  #bridgecrew:skip=BC_AWS_LOGGING_9:VPC Flow Logs are meant to be enabled by terraform-aws-vpc-flow-logs-s3-bucket and/or terraform-aws-cloudwatch-flow-logs
  #bridgecrew:skip=BC_AWS_NETWORKING_4:See aws_default_security_group.default for comments
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
  count = local.enable_default_security_group_with_custom_rules
  #bridgecrew:skip=BC_AWS_NETWORKING_4:This Bridgecrew policy checks for explicit ingress/egress blocks, however this default security group implementation does not add any inbound or outbound rules and is therefore inherently secure.
  vpc_id = join("", aws_vpc.default.*.id)

  tags = merge(module.label.tags, { Name = "Default Security Group" })
}

resource "aws_internet_gateway" "default" {
  count  = local.enable_internet_gateway
  vpc_id = join("", aws_vpc.default.*.id)
  tags   = module.label.tags
}

resource "aws_egress_only_internet_gateway" "default" {
  count  = local.enable_egress_only_internet_gateway
  vpc_id = join("", aws_vpc.default.*.id)
  tags   = module.label.tags
}

resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each   = toset(local.additional_cidr_blocks)
  vpc_id     = join("", aws_vpc.default.*.id)
  cidr_block = each.key
}
