locals {
  aws_region = "eu-west-2"
}

provider "aws" {
  region = local.aws_region
}

module "bucket" {
  source          = "../../module/s3-bucket-with-kms"
  label_namespace = "ex"
  label_stage     = "dev"
  label_name      = "example-bucket-with-kms"
  tags = {
    note = "Managed by Terraform"
  }
  # allow to destroy bucket (handy for an example)
  bucket_force_destroy = true
}
