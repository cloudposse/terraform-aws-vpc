# Define composite variables for resources
resource "null_resource" "default" {
  triggers = {
    id = "${lower(format("%v-%v-%v", var.namespace, var.stage, var.name))}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc" "default" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true

  tags {
    Name      = "${null_resource.default.triggers.id}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name      = "${null_resource.default.triggers.id}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }
}
