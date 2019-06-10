## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tag_map | Additional tags for appending to each tag map | map | `<map>` | no |
| attributes | Any extra attributes for naming these resources | list | `<list>` | no |
| cidr_block | CIDR for the VPC | string | - | yes |
| context | The context output from an external label module to pass to the label modules within this module | map | `<map>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| enable_classiclink | A boolean flag to enable/disable ClassicLink for the VPC | string | `false` | no |
| enable_classiclink_dns_support | A boolean flag to enable/disable ClassicLink DNS Support for the VPC | string | `false` | no |
| enable_dns_hostnames | A boolean flag to enable/disable DNS hostnames in the VPC | string | `true` | no |
| enable_dns_support | A boolean flag to enable/disable DNS support in the VPC | string | `true` | no |
| environment | The environment name if not using stage | string | `` | no |
| instance_tenancy | A tenancy option for instances launched into the VPC | string | `default` | no |
| label_order | The naming order of the id output and Name tag | list | `<list>` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | string | `` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | string | `` | no |
| regex_replace_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. By default only hyphens, letters and digits are allowed, all other chars are removed | string | `/[^a-zA-Z0-9-]/` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | `` | no |
| tags | Additional tags to apply to all resources that use this label module | map | `<map>` | no |

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
| vpc_main_route_table_id | The ID of the main route table associated with this VPC. |

