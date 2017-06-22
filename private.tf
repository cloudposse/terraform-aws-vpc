resource "aws_subnet" "private" {
  count = "${length(var.availability_zones)}"

  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, length(var.availability_zones), length(var.availability_zones)  + count.index)}"

  tags {
    Name      = "${null_resource.default.triggers.id}-private-${count.index+1}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
    Network   = "private"
  }
}

resource "aws_route_table" "private" {
  count = "${length(var.availability_zones)}"

  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.public.*.id, count.index)}"
  }

  tags {
    Name      = "${null_resource.default.triggers.id}-private-${count.index+1}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
    Network   = "private"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
