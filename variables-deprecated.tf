variable "enable_dns_hostnames" {
  type        = bool
  description = "DEPRECATED, use `dns_hostnames_enabled instead`: A boolean flag to enable/disable DNS hostnames in the VPC"
  default     = null
}

variable "enable_dns_support" {
  type        = bool
  description = "DEPRECATED, use `dns_support_enabled instead`: A boolean flag to enable/disable DNS support in the VPC"
  default     = null
}

variable "enable_classiclink" {
  type        = bool
  description = "DEPRECATED, use `classiclink_enabled instead`: A boolean flag to enable/disable ClassicLink for the VPC"
  default     = null
}

variable "enable_classiclink_dns_support" {
  type        = bool
  description = "DEPRECATED, use `classiclink_dns_support_enabled instead`: A boolean flag to enable/disable ClassicLink DNS Support for the VPC"
  default     = null
}

variable "enable_default_security_group_with_custom_rules" {
  type        = bool
  description = "OBSOLETE and never fully implemented. Replaced with `default_security_group_deny_all`."
  default     = null
}

variable "enable_internet_gateway" {
  type        = bool
  description = "DEPRECATED, use `internet_gateway_enabled` instead: A boolean flag to enable/disable Internet Gateway creation"
  default     = null
}

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "DEPRECATED, use `ipv6_enabled` instead: Whether to assign generated ipv6 cidr block to the VPC"
  default     = null
}
