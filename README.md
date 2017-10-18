# terraform-aws-vpc

Terraform module that defines a VPC with Internet Gateway


## Usage

```terraform
module "vpc" {
  name      = "${var.name}"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
}
```

## Inputs

| Name                               |    Default    | Description                                                                      | Required |
|:-----------------------------------|:-------------:|:---------------------------------------------------------------------------------|:--------:|
| `assign_generated_ipv6_cidr_block` |    `false`    | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC |    No    |
| `cidr_block`                       | `10.0.0.0/16` | CIDR for the VPC                                                                 |    No    |
| `enable_classiclink`               |    `false`    | A boolean flag to enable/disable ClassicLink for the VPC                         |    No    |
| `enable_classiclink_dns_support`   |    `false`    | A boolean flag to enable/disable ClassicLink DNS Support for the VPC             |    No    |
| `enable_dns_hostnames`             |    `true`     | A boolean flag to enable/disable DNS hostnames in the VPC                        |    No    |
| `enable_dns_support`               |    `true`     | A boolean flag to enable/disable DNS support in the VPC                          |    No    |
| `instance_tenancy`                 |      ``       | A tenancy option for instances launched into the VPC                             |    No    |
| `namespace`                        |      ``       | Namespace (e.g. `cp` or `cloudposse`)                                            |   Yes    |
| `stage`                            |      ``       | Stage (e.g. `prod`, `dev`, `staging`)                                            |   Yes    |
| `name`                             |      ``       | Name  (e.g. `bastion` or `db`)                                                   |   Yes    |
| `attributes`                       |     `[]`      | Additional attributes (e.g. `policy` or `role`)                                  |    No    |
| `tags`                             |     `{}`      | Additional tags  (e.g. `map("BusinessUnit","XYZ")`                               |    No    |
| `delimiter`                        |      `-`      | Delimiter to be used between `name`, `namespace`, `stage`, etc.                  |    No    |



## Outputs

| Name                            | Description                                                     |
|:--------------------------------|:----------------------------------------------------------------|
| `igw_id`                        | The ID of the Internet Gateway                                  |
| `ipv6_cidr_block`               | The IPv6 CIDR block                                             |
| `vpc_cidr_block`                | The CIDR block of the VPC                                       |
| `vpc_default_network_acl_id`    | The ID of the network ACL created by default on VPC creation    |
| `vpc_default_route_table_id`    | The ID of the route table created by default on VPC creation    |
| `vpc_default_security_group_id` | The ID of the security group created by default on VPC creation |
| `vpc_id`                        | The ID of the VPC                                               |
| `vpc_ipv6_association_id`       | The association ID for the IPv6 CIDR block                      |
| `vpc_main_route_table_id`       | The ID of the main route table associated with this VPC.        |



## License

Apache 2 License. See [`LICENSE`](LICENSE) for full details.
