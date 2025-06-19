terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}
