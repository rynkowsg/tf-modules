# ------------------------------------------------------------------------------
# BODY
# ------------------------------------------------------------------------------

locals {
  aws_region     = "eu-west-2"
}

provider "aws" {
  region = local.aws_region
}

module "backend" {
  source          = "../../module/backend-s3-aes"
  label_namespace = "ex"
  label_stage     = "dev"
  label_name      = "example-aes"
  tags = {
    note = "Managed by Terraform"
  }
  # allow to destroy bucket (handy for an example)
  bucket_force_destroy = true
}
