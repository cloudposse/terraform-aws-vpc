variable "vpc_id" {
  type        = string
  description = "VPC ID where the VPC Endpoints will be created (e.g. `vpc-aceb2723`)"
}

variable "gateway_vpc_endpoints" {
  type = map(object({
    name   = string
    policy = string
  }))
  description = "A map of Gateway VPC Endpoints to provision into the VPC. This is a map of objects with the following valid attributes: 'name' (either be one of 's3' or 'dynamodb') is required; 'policy' is optional and can be specified as null."
  default     = {}
}

variable "interface_vpc_endpoints" {
  type = map(object({
    name                = string
    subnet_ids          = list(string)
    policy              = string
    security_group_ids  = list(string)
    private_dns_enabled = bool
  }))
  description = "A map of Interface VPC Endpoints to provision into the VPC. This is a map of objects with the following valid attributes: 'name', 'security_group_ids', 'private_dns_enabled' are required; 'policy' and 'subnet_ids' are optional and can be specified as null and as an empty list, respectively."
  default     = {}
}