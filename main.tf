# Define composite variables for resources
module "label" {
  source    = "git::https://github.com/cloudposse/tf_label.git?ref=init"
  namespace = "${var.namespace}"
  name      = "${var.name}"
  stage     = "${var.stage}"
}


resource "aws_vpc" "default" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true

  tags {
    Name      = "${module.label.value}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name      = "${module.label.value}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }
}
