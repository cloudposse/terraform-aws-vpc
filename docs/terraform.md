## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list(string) | `<list>` | no |
| cidr_block | CIDR for the VPC | string | - | yes |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| enable_classiclink | A boolean flag to enable/disable ClassicLink for the VPC | bool | `false` | no |
| enable_classiclink_dns_support | A boolean flag to enable/disable ClassicLink DNS Support for the VPC | bool | `false` | no |
| enable_default_security_group_with_custom_rules | A boolean flag to enable/disable custom and restricive inbound/outbound rules for the default VPC's SG | bool | `true` | no |
| enable_dns_hostnames | A boolean flag to enable/disable DNS hostnames in the VPC | bool | `true` | no |
| enable_dns_support | A boolean flag to enable/disable DNS support in the VPC | bool | `true` | no |
| enable_internet_gateway | A boolean flag to enable/disable Internet Gateway provisioning | bool | `true` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | string | `` | no |
| instance_tenancy | A tenancy option for instances launched into the VPC | string | `default` | no |
| name | Name  (e.g. `app` or `cluster`) | string | - | yes |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | `` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`) | map(string) | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| igw_id | The ID of the Internet Gateway |
| ipv6_cidr_block | The IPv6 CIDR block |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_default_network_acl_id | The ID of the network ACL created by default on VPC creation |
| vpc_default_route_table_id | The ID of the route table created by default on VPC creation |
| vpc_default_security_group_id | The ID of the security group created by default on VPC creation |
| vpc_id | The ID of the VPC |
| vpc_ipv6_association_id | The association ID for the IPv6 CIDR block |
| vpc_main_route_table_id | The ID of the main route table associated with this VPC |

