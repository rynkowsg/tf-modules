locals {
  label_parts_except_extras = [var.label_namespace, var.label_region, var.label_stage, var.label_name]
  label_composed            = join("-", compact(concat(local.label_parts_except_extras, var.label_extras)))
  label_final               = coalesce(var.label_full, local.label_composed)
  bucket_name               = local.label_final
  kms_key_name              = "${local.bucket_name}-key"
}

# ------------------------------------------------------------------------------
# S3 BUCKET
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_18:TODO: add add options for logging
  #checkov:skip=CKV_AWS_144:TODO: add add options for CRR (cross-region replication)
  #checkov:skip=CKV2_AWS_62:TODO: add add options for event notifications
  bucket        = local.bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.this.bucket

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
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "this" {
  for_each = var.bucket_policy != null ? { "provided" = true } : {}
  bucket   = aws_s3_bucket.this.id
  policy   = var.bucket_policy
}

# ------------------------------------------------------------------------------
# BUCKET ENCRYPTION
# ------------------------------------------------------------------------------

locals {
  bucket_kms_key_policy_default = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.current_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowAccessFromSameAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.current_account_id}:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  bucket_kms_key_policy_final = var.bucket_kms_key_policy != null ? var.bucket_kms_key_policy : local.bucket_kms_key_policy_default
}

resource "aws_kms_key" "bucket_key" {
  description             = "KMS key for encrypting Terraform state"
  tags                    = var.tags
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = local.bucket_kms_key_policy_final
}

resource "aws_kms_alias" "bucket_key" {
  name          = "alias/${local.kms_key_name}"
  target_key_id = aws_kms_key.bucket_key.key_id
}

# Enable server-side encryption by default
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_key" {
  bucket     = aws_s3_bucket.this.id
  depends_on = [aws_kms_key.bucket_key]

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}
