output "public_subnet_cidrs" {
  value = module.subnets.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = module.subnets.private_subnet_cidrs
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "gateway_vpc_endpoints" {
  value = module.vpc_endpoints.gateway_vpc_endpoints
}

output "interface_vpc_endpoints" {
  value = module.vpc_endpoints.interface_vpc_endpoints
}