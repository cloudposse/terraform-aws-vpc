variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "namespace" {
  type = string
}

variable "name" {
  type = string
}

variable "stage" {
  type = string
}
