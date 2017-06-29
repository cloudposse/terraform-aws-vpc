variable "namespace" {
  default = "global"
}

variable "stage" {
  default = "default"
}

variable "name" {
  default = "vpc"
}

variable "availability_zones" {
  description = "Run the EC2 Instances in these Availability Zones"
  type        = "list"
}

variable "cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}
