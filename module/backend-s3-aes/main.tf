locals {
  label_extras_default = ["terraform", "state"]
  label_extras_final   = length(var.label_extras) != 0 ? var.label_extras : local.label_extras_default
  bucket_name          = join("-", compact(concat([var.label_namespace, var.label_region, var.label_stage, var.label_name], local.label_extras_final)))
  kms_key_name         = "${local.bucket_name}-key"
}

# ------------------------------------------------------------------------------
# S3 BUCKET
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV_AWS_18:Logging is not crucial for Terraform state bucket
  #checkov:skip=CKV_AWS_144:CRR (cross-region replication) not required for Terraform state bucket
  #checkov:skip=CKV_AWS_145:This module by definition uses AES encryption.
  #checkov:skip=CKV2_AWS_62:Event notifications enabled not necessary for Terraform state bucket
  bucket        = local.bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    id     = "RetainTerraformState"
    status = "Enabled"

    filter {} # Applies to all objects

    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Enable versioning by default
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# ------------------------------------------------------------------------------
# BUCKET ENCRYPTION
# ------------------------------------------------------------------------------

# Enable server-side encryption by default
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
