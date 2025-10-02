terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.16"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.8.0"
    }
  }
}
