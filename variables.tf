variable "cidr_block" {
  type        = string
  description = "CIDR for the VPC"
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC"
  default     = true
}

variable "enable_classiclink" {
  type        = bool
  description = "A boolean flag to enable/disable ClassicLink for the VPC"
  default     = false
}

variable "enable_classiclink_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable ClassicLink DNS Support for the VPC"
  default     = false
}

variable "security_group_enabled" {
  type        = bool
  description = "Whether to create default Security Group for VPC."
  default     = true
}

variable "security_group_description" {
  type        = string
  default     = "VPC Security Group"
  description = "The Security Group description."
}

variable "security_group_use_name_prefix" {
  type        = bool
  default     = false
  description = "Whether to create a default Security Group with unique name beginning with the normalized prefix."
}

variable "security_group_rules" {
  type = list(any)
  default = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow ALL egress traffic"
    }
  ]
  description = <<-EOT
    A list of maps of Security Group rules. 
    The values of map is fully complated with `aws_security_group_rule` resource. 
    To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule .
  EOT
}

variable "enable_internet_gateway" {
  type        = bool
  description = "A boolean flag to enable/disable Internet Gateway creation"
  default     = true
}

variable "additional_cidr_blocks" {
  type        = list(string)
  description = "A list of additional IPv4 CIDR blocks to associate with the VPC"
  default     = null
}

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "Whether to assign generated ipv6 cidr block to the VPC"
  default     = true
}
