variable "region" {
  type = string
  description = "The region to use for the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to use for the VPC"
}

variable "default_security_group_deny_all" {
  type        = bool
  description = "Whether to deny all ingress and egress traffic on the default security group"
}

variable "default_route_table_no_routes" {
  type        = bool
  description = "Whether to remove all routes from the default route table"
}

variable "default_network_acl_deny_all" {
  type        = bool
  description = "Whether to deny all ingress and egress traffic on the default network ACL"
}

variable "network_address_usage_metrics_enabled" {
  type        = bool
  description = "Whether to enable network address usage metrics"
}
