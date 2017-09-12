variable "namespace" {}

variable "stage" {}

variable "name" {}

variable "cidr_block" {
  description = "CIDR for the entire VPC"
}

variable "delimiter" {
  default = "-"
}

variable "attributes" {
  type    = "list"
  default = []
}

variable "tags" {
  type    = "map"
  default = {}
}

variable "region" {}
