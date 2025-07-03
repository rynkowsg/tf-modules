output "bucket" {
  value = {
    "arn" : aws_s3_bucket.this.arn,
    "name" : aws_s3_bucket.this.bucket,
  }
}

output "kms_key" {
  value = {
    "arn" : aws_kms_key.bucket_key.arn,
    "id" : aws_kms_key.bucket_key.id,
    "alias" : aws_kms_alias.bucket_key.name,
    "alias_arn" : aws_kms_alias.bucket_key.arn,
  }
}
