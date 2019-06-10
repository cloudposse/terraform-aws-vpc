module "vpc" {
  # source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  source     = "../../"
  context    = "${module.label.context}"
  cidr_block = "${var.cidr_block}"
}

module "dynamic_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  context             = "${module.label.context}"
  region              = "${var.region}"
  availability_zones  = "${var.availability_zones}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${var.cidr_block}"
  nat_gateway_enabled = "false"
}

module "label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  delimiter = "-"

  tags = {
    "ManagedBy" = "Terraform"
    "ModuleBy"  = "CloudPosse"
  }
}
