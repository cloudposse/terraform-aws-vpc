output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "public_subnets" {
  value = ["${module.subnets.public_subnet_ids}"]
}

output "private_subnets" {
  value = ["${module.subnets.private_subnet_ids}"]
}
