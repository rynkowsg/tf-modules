locals {
  aws_region = "eu-west-2"
}

provider "aws" {
  region = local.aws_region
}
