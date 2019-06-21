module "vpc" {
  source = "../../"

  providers = {
    aws = "aws"
  }

  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  #source = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.13.0"
  source = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=update-tests"

  providers = {
    aws = "aws"
  }

  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
}
