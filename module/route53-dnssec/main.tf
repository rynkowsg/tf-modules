locals {
  domain_dashed = replace(var.domain, ".", "-")
}

resource "aws_kms_key" "default" {
  description             = "KMS key for ${var.domain} DNSSEC"

  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "ECC_NIST_P256"

  # key rotation is not supported on asymmetric KMS key
  enable_key_rotation     = false
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${local.current_account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow Route 53 DNSSEC Service to use the key",
        "Effect": "Allow",
        "Principal": {
          "Service": "dnssec-route53.amazonaws.com"
        },
        "Action": [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "aws:SourceAccount": local.current_account_id
          },
          "ArnLike": {
            "aws:SourceArn": "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        "Sid": "Allow Route 53 DNSSEC to CreateGrant",
        "Effect": "Allow",
        "Principal": {
          "Service": "dnssec-route53.amazonaws.com"
        },
        "Action": "kms:CreateGrant",
        "Resource": "*",
        "Condition": {
          "Bool": {
            "kms:GrantIsForAWSResource": "true"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "default" {
  name          = "alias/dnssec-key-for-${local.domain_dashed}"
  target_key_id = aws_kms_key.default.key_id

  depends_on = [aws_kms_key.default]
}

resource "aws_route53_key_signing_key" "default" {
  hosted_zone_id             = var.hosted_zone_id
  key_management_service_arn = aws_kms_key.default.arn
  name                       = local.domain_dashed

  depends_on = [aws_kms_key.default]
}

# Enable DNSSEC for the hosted zone
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_hosted_zone_dnssec
resource "aws_route53_hosted_zone_dnssec" "default" {
  hosted_zone_id = var.hosted_zone_id

  depends_on = [
    aws_route53_hosted_zone_dnssec.default,
    aws_route53_key_signing_key.default,
  ]
}
