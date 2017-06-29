resource "aws_subnet" "public" {
  count = "${length(var.availability_zones)}"

  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, length(var.availability_zones), count.index)}"

  tags {
    Name      = "${module.label.id}-public-${count.index+1}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
    Network   = "public"
  }
}

resource "aws_eip" "nat" {
  count = "${length(var.availability_zones)}"
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "public" {
  count         = "${length(var.availability_zones)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "public" {
  count = "${length(var.availability_zones)}"

  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name      = "${module.label.id}-public-${count.index+1}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
    Network   = "public"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}
