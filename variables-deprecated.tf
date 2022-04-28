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

variable "ipv6_enabled" {
  type        = bool
  description = <<-EOT
    DEPRECATED: use `assign_generated_ipv6_cidr_block` or `ipv6_ipam_pool_id` instead.
    Historical description: If `true`, enable IPv6 and assign a generated CIDR block to the VPC"
    EOT
  default     = null
}

variable "cidr_block" {
  type        = string
  description = <<-EOT
    DEPRECATED: Use `ipv4_primary_cidr_block` instead.
    Historical description: The IPv4 CIDR block for the VPC.
    Either `cidr_block` or `ipv4_ipam_pool_id` must be set, but not both.
    EOT
  default     = null
}

variable "additional_cidr_blocks" {
  type        = list(string)
  description = <<-EOT
    DEPRECATED: Use `ipv4_additional_cidr_block_associations` instead.
    A list of additional IPv4 CIDR blocks to associate with the VPC
    EOT
  default     = []
}

