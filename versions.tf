terraform {
  required_version = "~> 0.12.0"
}

# Pin the `aws` provider
# https://www.terraform.io/docs/configuration/providers.html
provider "aws" {
  version = ">= 2.12.0"
}
