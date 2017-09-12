output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "cidr_block" {
  value = "${aws_vpc.default.cidr_block}"
}

output "internet_gateway_id" {
  value = "${aws_internet_gateway.default.id}"
}
