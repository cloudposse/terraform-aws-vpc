output "public_subnet_cidrs" {
  value       = module.subnets.public_subnet_cidrs
  description = "The CIDR block ranges of the public subnets belonging to the VPC."
}

output "private_subnet_cidrs" {
  value       = module.subnets.private_subnet_cidrs
  description = "The CIDR block ranges of the private subnets belonging to the VPC."
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr_block
  description = "The CIDR block range of the VPC."
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "gateway_vpc_endpoints" {
  value       = module.vpc_endpoints.gateway_vpc_endpoints
  description = "List of Gateway VPC Endpoints deployed to the VPC."
}

output "interface_vpc_endpoints" {
  value       = module.vpc_endpoints.interface_vpc_endpoints
  description = "List of Interface VPC Endpoints deployed to the VPC."
}