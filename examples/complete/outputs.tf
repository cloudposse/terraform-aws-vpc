output "public_subnet_cidrs" {
  value = module.subnets.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = module.subnets.private_subnet_cidrs
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "security_group_id" {
  value       = module.vpc.security_group_id
  description = "VPC Security Group ID"
}

output "security_group_arn" {
  value       = module.vpc.security_group_arn
  description = "VPC Security Group ARN"
}

output "security_group_name" {
  value       = module.vpc.security_group_name
  description = "VPC Security Group name"
}
