output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "public_subnet_ids" {
  value = ["${module.subnets.public_subnet_ids}"]
}

output "private_subnet_ids" {
  value = ["${module.subnets.private_subnet_ids}"]
}
