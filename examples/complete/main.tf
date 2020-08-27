provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "../../"
  cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  # Temporary example until we can update terraform-aws-dynamic-subnets, which
  # has a circular dependency on this module
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.27.0"
  availability_zones   = var.availability_zones
  namespace            = module.this.context.namespace
  stage                = module.this.context.stage
  name                 = module.this.context.name
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
}
