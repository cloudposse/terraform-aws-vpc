variable "namespace" {
  default = ""
}

variable "stage" {
  default = ""
}

variable "name" {
  default = ""
}

variable "availability_zones" {
  description = "Run the EC2 Instances in these Availability Zones"
  type        = "list"
}

variable "cidr_block" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "region" {
  default = ""
}

variable "igw_id" {
  default = ""
}
