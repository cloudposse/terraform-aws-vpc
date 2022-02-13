variable "cidr_block" {
  type        = string
  description = <<-EOT
    The IPv4 CIDR block for the VPC.
    Either `cidr_block` or `ipv4_ipam_pool_id` must be set, but not both.
    EOT
  default     = null
}

variable "ipv4_ipam_pool_id" {
  type        = string
  description = <<-EOT
    The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR.
    Either `cidr_block` or `ipv4_ipam_pool_id` must be set, but not both.
    EOT
  default     = null
}

variable "ipv4_netmask_length" {
  type        = number
  description = "The netmask length of the IPv4 CIDR you want to allocate to this VPC."
  default     = 16
}
locals { ipv4_netmask_length = var.ipv4_ipam_pool_id != null ? var.ipv4_netmask_length : null }

variable "additional_cidr_blocks" {
  type        = list(string)
  description = "A list of additional IPv4 CIDR blocks to associate with the VPC"
  default     = []
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.instance_tenancy)
    error_message = "Instance tenancy must be one of \"default\", \"dedicated\", or \"host\"."
  }
}

variable "dns_hostnames_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  default     = true
}
locals { dns_hostnames_enabled = coalesce(var.enable_dns_hostnames, var.dns_hostnames_enabled) }

variable "dns_support_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC"
  default     = true
}
locals { dns_support_enabled = coalesce(var.enable_dns_support, var.dns_support_enabled) }

variable "classiclink_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable ClassicLink for the VPC"
  default     = false
}
locals { classiclink_enabled = coalesce(var.enable_classiclink, var.classiclink_enabled) }

variable "classiclink_dns_support_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable ClassicLink DNS Support for the VPC"
  default     = false
}
locals { classiclink_dns_support_enabled = coalesce(var.enable_classiclink_dns_support, var.classiclink_dns_support_enabled) }

variable "default_security_group_deny_all" {
  type        = bool
  default     = true
  description = <<-EOT
    When `true`, manage the default security group and remove all rules, disabling all ingress and egress.
    When `false`, do not manage the default security group, allowing it to be managed by another component
    EOT
}
locals { default_security_group_deny_all = local.enabled && coalesce(var.enable_default_security_group_with_custom_rules, var.default_security_group_deny_all) }

variable "internet_gateway_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable Internet Gateway creation"
  default     = true
}
locals { internet_gateway_enabled = local.enabled && coalesce(var.enable_internet_gateway, var.internet_gateway_enabled) }

variable "ipv6_enabled" {
  type        = bool
  description = "If `true`, enable IPv6 and assign a generated CIDR block to the VPC"
  default     = true
}
locals { ipv6_enabled = coalesce(var.assign_generated_ipv6_cidr_block, var.ipv6_enabled) }

variable "ipv6_egress_only_internet_gateway_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable IPv6 Egress-Only Internet Gateway creation"
  default     = false
}
