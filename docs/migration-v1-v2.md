# Migration Notes for VPC v2.0

## Key changes in v2.0

Minimum version changes:
- Terraform: v0.13.0 -> v1.0.0
- AWS Provider: v3.0 -> v4.9.0

#### vpc
- Remove support for EC2-Classic and ClassicLink since [AWS is retiring it](https://aws.amazon.com/blogs/aws/ec2-classic-is-retiring-heres-how-to-prepare/)
- Remove variables deprecated in v1.0

#### vpc//modules/vpc-endpoints
- Add `route_table_ids` to `gateway_vpc_endpoints` and create route table associations for Gateway endpoints
- Replace inline Route Table, Security Group, and Subnet associations with standalone Terraform resources

## Migration Guide

#### vpc

Existing VPCs should be able to upgrade to v2.0 without any change to the VPC or
other AWS resources, unless they were using EC2-Classic ClassicLink. 

Other variables that were deprecated in v1.0 have been removed in v2.0, 
but for the most part they have just been renamed. Update your
code as follows:

- Remove `enable_classiclink` and `classiclink_enabled` as they are no longer supported
- Remove `enable_classiclink_dns_support` and `classiclink_dns_support_enabled` as they are no longer supported
- Replace `enable_dns_hostnames` with `dns_hostnames_enabled`
- Replace `enable_dns_support` with `dns_support_enabled`
- If you were using `enable_default_security_group_with_custom_rule`, review what it was actually doing, 
because it was never fully implemented. Use `default_security_group_deny_all` to deny all traffic to the default security group.
- Replace `cidr_block` with `ipv4_primary_cidr_block` or use `ipv4_ipam_pool_id` instead
- Replace `ipv6_enabled` with `assign_generated_ipv6_cidr_block` or use `ipv6_ipam_pool_id` instead
- Replace `additional_cidr_blocks` with `ipv4_additional_cidr_block_associations`. 
If migrating to `ipv4_additional_cidr_block_associations` and not using IPAM, set the map keys
to the value of `ipv4_cidr_block` to avoid Terraform changes.

#### vpc-endpoints

You will need to add `route_table_ids` to `gateway_vpc_endpoints`, but it can be an empty list.

Terraform plan may show changes, but they should not have any effect.

Outputs have changed from lists to maps, so that you can use the keys you provided
in the input maps to find the information for the relevant endpoint.
