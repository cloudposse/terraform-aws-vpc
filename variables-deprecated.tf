variable "enable_dns_hostnames" {
  type        = bool
  description = "DEPRECATED, use `dns_hostnames_enabled instead`: A boolean flag to enable/disable DNS hostnames in the VPC"
  default     = null
}
locals { dns_hostnames_enabled = coalesce(var.enable_dns_hostnames, var.dns_hostnames_enabled) }

variable "enable_dns_support" {
  type        = bool
  description = "DEPRECATED, use `dns_support_enabled instead`: A boolean flag to enable/disable DNS support in the VPC"
  default     = null
}
locals { dns_support_enabled = coalesce(var.enable_dns_support, var.dns_support_enabled) }

variable "enable_classiclink" {
  type        = bool
  description = "DEPRECATED, use `classiclink_enabled instead`: A boolean flag to enable/disable ClassicLink for the VPC"
  default     = null
}
locals { classiclink_enabled = coalesce(var.enable_classiclink, var.classiclink_enabled) }

variable "enable_classiclink_dns_support" {
  type        = bool
  description = "DEPRECATED, use `classiclink_dns_support instead`: A boolean flag to enable/disable ClassicLink DNS Support for the VPC"
  default     = null
}
locals { classiclink_dns_support = coalesce(var.enable_classiclink_dns_support, var.classiclink_dns_support) }

variable "enable_default_security_group_with_custom_rules" {
  type        = bool
  description = "OBSOLETE and never fully implmented. Replaced with `default_security_group_deny_all`."
  default     = null
}
locals { default_security_group_deny_all = local.enabled && coalesce(var.enable_default_security_group_with_custom_rules, var.default_security_group_deny_all) }

variable "enable_internet_gateway" {
  type        = bool
  description = "DEPRECATED, use `internet_gateway_enabled` instead: A boolean flag to enable/disable Internet Gateway creation"
  default     = null
}
locals { internet_gateway_enabled = local.enabled && coalesce(var.enable_internet_gateway, var.internet_gateway_enabled) }

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "DEPRECATED, use `ipv6_enabled` instead: Whether to assign generated ipv6 cidr block to the VPC"
  default     = null
}
locals { ipv6_enabled = coalesce(var.assign_generated_ipv6_cidr_block, var.ipv6_enabled) }
