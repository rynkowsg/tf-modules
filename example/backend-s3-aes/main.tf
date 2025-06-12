# ------------------------------------------------------------------------------
# BODY
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = "eu-west-2"
}

provider "aws" {
  region = local.aws_region
}

module "backend" {
  source          = "../../module/backend-s3-aes"
  aws_region      = local.aws_region
  aws_account_id  = local.aws_account_id
  label_namespace = "ex"
  label_stage     = "dev"
  label_name      = "example"
  tags = {
    note = "Managed by Terraform"
  }
  # allow to destroy bucket (handy for an example)
  bucket_force_destroy = true
}
