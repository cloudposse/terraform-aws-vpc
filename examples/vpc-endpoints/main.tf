provider "aws" {
  region = var.region
}

locals {
  gateway_vpc_endpoints = {
    "s3" = {
      name = "s3"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "s3:*",
            ]
            Effect    = "Allow"
            Principal = "*"
            Resource  = "*"
          },
        ]
      })
    }
    "dynamodb" = {
      name   = "dynamodb"
      policy = null
    }
  }
  interface_vpc_endpoints = {
    "ec2" = {
      name                = "ec2"
      security_group_ids  = [aws_security_group.ec2_vpc_endpoint_sg.id]
      subnet_ids          = module.subnets.private_subnet_ids
      policy              = null
      private_dns_enabled = true
    }
    "kinesis-streams" = {
      name                = "kinesis-streams"
      security_group_ids  = [aws_security_group.kinesis_vpc_endpoint_sg.id]
      subnet_ids          = module.subnets.private_subnet_ids
      policy              = null
      private_dns_enabled = false
    }
  }
}

module "vpc" {
  source     = "../../"
  cidr_block = "172.17.0.0/16"

  context = module.this.context
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  gateway_vpc_endpoints   = local.gateway_vpc_endpoints
  interface_vpc_endpoints = local.interface_vpc_endpoints

  context = module.this.context
}


module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.39.0"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "ec2_vpc_endpoint_sg_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["ec2-vpc-endpoint-sg"]

  context = module.this.context
}

module "kinesis_vpc_endpoint_sg_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["kinesis-vpc-endpoint-sg"]

  context = module.this.context
}

resource "aws_security_group" "ec2_vpc_endpoint_sg" {
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Security Group for EC2 Interface VPC Endpoint"
  }

  tags = module.ec2_vpc_endpoint_sg_label.tags
}

resource "aws_security_group" "kinesis_vpc_endpoint_sg" {
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Security Group for Kinesis Interface VPC Endpoint"
  }

  tags = module.kinesis_vpc_endpoint_sg_label.tags
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_vpc_endpoint_route_table_association" {
  route_table_id  = module.vpc.vpc_main_route_table_id
  vpc_endpoint_id = module.vpc_endpoints.gateway_vpc_endpoints[0].id
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_gateway_vpc_endpoint_route_table_association" {
  route_table_id  = module.vpc.vpc_main_route_table_id
  vpc_endpoint_id = module.vpc_endpoints.gateway_vpc_endpoints[1].id
}