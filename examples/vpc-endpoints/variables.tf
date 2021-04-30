variable "region" {
  type        = string
  description = "The AWS region where the VPC to deploy the VPC and the VPC endpoints to."
}

variable "availability_zones" {
  type        = list(string)
  description = "The list of Availability Zones within the AWS region to deploy the VPC's subnets into."
}