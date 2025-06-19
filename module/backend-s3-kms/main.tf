locals {
  label_parts_except_extras = [var.label_namespace, var.label_region, var.label_stage, var.label_name]
  label_composed            = join("-", compact(concat(local.label_parts_except_extras, var.label_extras)))
  label_composed_or_default = length(local.label_composed) > 0 ? local.label_composed : "terraform-state"
  label_final               = coalesce(var.label_full, local.label_composed_or_default)
  bucket_name               = local.label_final
  kms_key_name              = "${local.bucket_name}-key"
}

# ------------------------------------------------------------------------------
# S3 BUCKET
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV_AWS_18:Logging is not crucial for Terraform state bucket
  #checkov:skip=CKV_AWS_144:CRR (cross-region replication) not required for Terraform state bucket
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

locals {
  root_statement = {
    Sid    = "AllowRootAccount"
    Effect = "Allow"
    Principal = {
      AWS = "arn:aws:iam::${var.aws_account_id}:root"
    }
    Action   = "kms:*"
    Resource = "*"
  }
  admin_statement = length(var.admin_principal_arns) > 0 ? {
    Sid    = "AllowAdministratorsGroupViaRole"
    Effect = "Allow"
    Principal = {
      AWS = var.admin_principal_arns
    }
    Action = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    Resource = "*"
  } : null
  policy_statements = concat([local.root_statement], local.admin_statement != null ? [local.admin_statement] : [])
}

resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for encrypting Terraform state"
  tags                    = var.tags
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version   = "2012-10-17",
    Id        = "default",
    Statement = local.policy_statements,
  })
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${local.kms_key_name}"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# Enable server-side encryption by default
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket     = aws_s3_bucket.terraform_state.id
  depends_on = [aws_kms_key.terraform_state]

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
