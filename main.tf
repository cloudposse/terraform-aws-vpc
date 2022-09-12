locals {
  enabled                                   = module.this.enabled
  ipv6_egress_only_internet_gateway_enabled = local.enabled && var.ipv6_egress_only_internet_gateway_enabled
  additional_cidr_blocks_map = local.enabled ? {
    for v in var.additional_cidr_blocks : v => {
      ipv4_cidr_block     = v
      ipv4_ipam_pool_id   = null
      ipv4_netmask_length = null
    }
  } : {}
  ipv4_cidr_block_associations = local.enabled ? (
    length(local.additional_cidr_blocks_map) > 0 ? local.additional_cidr_blocks_map : var.ipv4_additional_cidr_block_associations
  ) : {}
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}

resource "aws_vpc" "default" {
  count = local.enabled ? 1 : 0

  #bridgecrew:skip=BC_AWS_LOGGING_9:VPC Flow Logs are meant to be enabled by terraform-aws-vpc-flow-logs-s3-bucket and/or terraform-aws-cloudwatch-flow-logs
  cidr_block          = local.ipv4_primary_cidr_block
  ipv4_ipam_pool_id   = try(var.ipv4_primary_cidr_block_association.ipv4_ipam_pool_id, null)
  ipv4_netmask_length = try(var.ipv4_primary_cidr_block_association.ipv4_netmask_length, null)
  # Additional IPv4 CIDRs are handled by aws_vpc_ipv4_cidr_block_association below

  ipv6_cidr_block     = try(var.ipv6_primary_cidr_block_association.ipv6_cidr_block, null)
  ipv6_ipam_pool_id   = try(var.ipv6_primary_cidr_block_association.ipv6_ipam_pool_id, null)
  ipv6_netmask_length = try(var.ipv6_primary_cidr_block_association.ipv6_netmask_length, null)
  # Additional IPv6 CIDRs are handled by aws_vpc_ipv6_cidr_block_association below

  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = local.dns_hostnames_enabled
  enable_dns_support               = local.dns_support_enabled
  enable_classiclink               = local.classiclink_enabled
  enable_classiclink_dns_support   = local.classiclink_dns_support_enabled
  assign_generated_ipv6_cidr_block = local.assign_generated_ipv6_cidr_block
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
  for_each = local.enabled ? local.ipv4_cidr_block_associations : {}

  cidr_block          = each.value.ipv4_cidr_block
  ipv4_ipam_pool_id   = each.value.ipv4_ipam_pool_id
  ipv4_netmask_length = each.value.ipv4_netmask_length

  vpc_id = aws_vpc.default[0].id

  dynamic "timeouts" {
    for_each = local.enabled && var.ipv4_cidr_block_association_timeouts != null ? [true] : []
    content {
      create = lookup(var.ipv4_cidr_block_association_timeouts, "create", null)
      delete = lookup(var.ipv4_cidr_block_association_timeouts, "delete", null)
    }
  }
}

resource "aws_vpc_ipv6_cidr_block_association" "default" {
  for_each = local.enabled ? var.ipv6_additional_cidr_block_associations : {}

  ipv6_cidr_block     = each.value.ipv6_cidr_block
  ipv6_ipam_pool_id   = each.value.ipv6_ipam_pool_id
  ipv6_netmask_length = each.value.ipv6_netmask_length

  vpc_id = aws_vpc.default[0].id

  dynamic "timeouts" {
    for_each = local.enabled && var.ipv6_cidr_block_association_timeouts != null ? [true] : []
    content {
      create = lookup(var.ipv6_cidr_block_association_timeouts, "create", null)
      delete = lookup(var.ipv6_cidr_block_association_timeouts, "delete", null)
    }
  }
}

resource "aws_default_route_table" "default" {
  count                  = local.enabled ? 1 : 0
  default_route_table_id = aws_vpc.default[0].id
  tags = merge(module.label.tags, {
    Name = join(module.label.delimiter, [module.label.id, "default"])
  })
}
