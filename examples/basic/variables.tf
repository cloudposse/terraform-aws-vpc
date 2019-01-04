variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. eg)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Application or solution name (e.g. `app`)"
}

variable "region" {
  type        = "string"
  description = "Region for VPC"
}

variable "availability_zones" {
  type        = "list"
  description = "Availability zones to use within region"
}

variable "cidr_block" {
  type        = "string"
  description = "Classless Inter-Domain Routing block"
}
