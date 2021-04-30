output "gateway_vpc_endpoints" {
  value       = values(aws_vpc_endpoint.gateway_endpoint)
  description = "List of Gateway VPC Endpoints deployed to this VPC."
}

output "interface_vpc_endpoints" {
  value       = values(aws_vpc_endpoint.interface_endpoint)
  description = "List of Interface VPC Endpoints deployed to this VPC."
}