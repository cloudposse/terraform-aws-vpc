# terraform-aws-vpc [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-vpc.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-vpc)

Terraform module to provision a VPC with Internet Gateway.


## Usage

* Quick start example:

```hcl
module "vpc" {
  source    = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace = "cp"
  stage     = "prod"
  name      = "app"
}
```

* Full example with [`terraform-aws-dynamic-subnets`](https://github.com/cloudposse/terraform-aws-dynamic-subnets.git):

```hcl
module "vpc" {
  source    = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace = "cp"
  stage     = "prod"
  name      = "app"
}

module "dynamic_subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  namespace          = "cp"
  stage              = "prod"
  name               = "app"
  region             = "us-west-2"
  availability_zones = ["us-west-2a","us-west-2b","us-west-2c"]
  vpc_id             = "${module.vpc.vpc_id}"
  igw_id             = "${module.vpc.igw_id}"
  cidr_block         = "10.0.0.0/16"
}
```


## Inputs

| Name                               |    Default    | Description                                                                      | Required |
|:-----------------------------------|:-------------:|:---------------------------------------------------------------------------------|:--------:|
| `namespace`                        |      ``       | Namespace (e.g. `cp` or `cloudposse`)                                            |   Yes    |
| `stage`                            |      ``       | Stage (e.g. `prod`, `dev`, `staging`)                                            |   Yes    |
| `name`                             |      ``       | Name  (e.g. `app` or `cluster`)                                                  |   Yes    |
| `cidr_block`                       | `10.0.0.0/16` | CIDR block for the VPC                                                           |    No    |
| `enable_classiclink`               |    `false`    | A boolean flag to enable/disable ClassicLink for the VPC                         |    No    |
| `enable_classiclink_dns_support`   |    `false`    | A boolean flag to enable/disable ClassicLink DNS Support for the VPC             |    No    |
| `enable_dns_hostnames`             |    `true`     | A boolean flag to enable/disable DNS hostnames in the VPC                        |    No    |
| `enable_dns_support`               |    `true`     | A boolean flag to enable/disable DNS support in the VPC                          |    No    |
| `instance_tenancy`                 |   `default`   | A tenancy option for instances launched into the VPC                             |    No    |
| `attributes`                       |     `[]`      | Additional attributes (e.g. `1`)                                                 |    No    |
| `tags`                             |     `{}`      | Additional tags  (e.g. `map("BusinessUnit","XYZ")`                               |    No    |
| `delimiter`                        |     `-`       | Delimiter to be used between `namespace`, `stage`, `name` and `attributes`       |    No    |



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



## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-vpc/issues), send us an [email](mailto:hello@cloudposse.com) or reach out to us on [Gitter](https://gitter.im/cloudposse/).


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-vpc/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing `terraform-aws-vpc`, we would love to hear from you! Shoot us an [email](mailto:hello@cloudposse.com).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

**NOTE:** Be sure to merge the latest from "upstream" before making a pull request!


## License

[APACHE 2.0](LICENSE) © 2018 [Cloud Posse, LLC](https://cloudposse.com)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.


## About

`terraform-aws-vpc` is maintained and funded by [Cloud Posse, LLC][website].

![Cloud Posse](https://cloudposse.com/logo-300x69.png)


Like it? Please let us know at <hello@cloudposse.com>

We love [Open Source Software](https://github.com/cloudposse/)!

See [our other projects][community]
or [hire us][hire] to help build your next cloud platform.

  [website]: https://cloudposse.com/
  [community]: https://github.com/cloudposse/
  [hire]: https://cloudposse.com/contact/


## Contributors

| [![Erik Osterman][erik_img]][erik_web]<br/>[Erik Osterman][erik_web] | [![Andriy Knysh][andriy_img]][andriy_web]<br/>[Andriy Knysh][andriy_web] |[![Igor Rodionov][igor_img]][igor_web]<br/>[Igor Rodionov][igor_img]
|-------------------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------|

[erik_img]: http://s.gravatar.com/avatar/88c480d4f73b813904e00a5695a454cb?s=144
[erik_web]: https://github.com/osterman/
[andriy_img]: https://avatars0.githubusercontent.com/u/7356997?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
[andriy_web]: https://github.com/aknysh/
[igor_img]: http://s.gravatar.com/avatar/bc70834d32ed4517568a1feb0b9be7e2?s=144
[igor_web]: https://github.com/goruha/
