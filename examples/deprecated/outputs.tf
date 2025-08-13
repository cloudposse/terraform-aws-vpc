output "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  value       = module.subnets.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  value       = module.subnets.private_subnet_cidrs
}

output "vpc_cidr" {
  description = "The CIDR block for the VPC"
  value       = module.vpc.vpc_cidr_block
}
