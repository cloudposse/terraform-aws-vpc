variable "region" {
  type = string
  description = "The region to use for the VPC"
}

variable "availability_zones" {
  type = list(string)
  description = "The availability zones to use for the VPC"
}
