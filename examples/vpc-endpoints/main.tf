provider "aws" {
  region = var.region
}

locals {
  enabled    = module.this.enabled
  interfaces = ["ec2", "kinesis"]

  gateway_vpc_endpoints = {
    "s3" = {
      name = "s3"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "s3:*",
            ]
            Effect    = "Allow"
            Principal = "*"
            Resource  = "*"
          },
        ]
      })
      route_table_ids = [aws_route_table.other.id, module.vpc.vpc_default_route_table_id]
    }
    "dynamodb" = {
      name            = "dynamodb"
      policy          = null
      route_table_ids = [aws_route_table.other.id]
    }
  }
  interface_vpc_endpoints = {
    "ec2" = {
      name                = "ec2"
      security_group_ids  = [module.vpc.vpc_default_security_group_id, module.endpoint_security_groups[local.interfaces[0]].id]
      subnet_ids          = module.subnets.private_subnet_ids
      policy              = null
      private_dns_enabled = true
    }
    "kinesis-streams" = {
      name                = "kinesis-streams"
      security_group_ids  = [module.endpoint_security_groups[local.interfaces[1]].id, module.vpc.vpc_default_security_group_id]
      subnet_ids          = module.subnets.private_subnet_ids
      policy              = null
      private_dns_enabled = false
    }
  }
}

module "vpc" {
  source                   = "../../"
  ipv4_primary_cidr_block  = "172.17.0.0/16"
  internet_gateway_enabled = false

  context = module.this.context
}

resource "aws_route_table" "other" {
  vpc_id = module.vpc.vpc_id
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  gateway_vpc_endpoints   = local.gateway_vpc_endpoints
  interface_vpc_endpoints = local.interface_vpc_endpoints

  context = module.this.context
}


module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.0.4"

  availability_zones     = var.availability_zones
  vpc_id                 = module.vpc.vpc_id
  igw_id                 = []
  ipv4_cidr_block        = [module.vpc.vpc_cidr_block]
  public_subnets_enabled = false
  nat_gateway_enabled    = false
  nat_instance_enabled   = false

  context = module.this.context
}

module "endpoint_security_groups" {
  for_each = local.enabled ? toset(local.interfaces) : []
  source   = "cloudposse/security-group/aws"
  version  = "2.0.0-rc1"

  create_before_destroy      = true
  preserve_security_group_id = false
  attributes                 = [each.value]
  vpc_id                     = module.vpc.vpc_id

  rules = [{
    key              = "vpc_ingress"
    type             = "ingress"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = compact(concat([module.vpc.vpc_cidr_block], module.vpc.additional_cidr_blocks))
    ipv6_cidr_blocks = compact(concat([module.vpc.vpc_ipv6_cidr_block], module.vpc.additional_ipv6_cidr_blocks))
    description      = "Ingress from VPC to ${each.value}"
  }]

  allow_all_egress = true

  context = module.this.context
}
