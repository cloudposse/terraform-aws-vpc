variable "namespace" {
  type = "string"
}

variable "stage" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "availability_zones" {
  type        = "string"
  description = "List of Availability Zones"
  type        = "list"
}

variable "cidr_block" {
  type        = "string"
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "region" {
  type = "string"
}

variable "igw_id" {
  type = "string"
}
