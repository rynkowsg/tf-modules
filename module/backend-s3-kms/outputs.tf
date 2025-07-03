output "bucket" {
  value = {
    "arn" : aws_s3_bucket.terraform_state.arn,
    "name" : aws_s3_bucket.terraform_state.bucket,
  }
}

output "kms_key" {
  value = {
    "arn" : aws_kms_key.terraform_state.arn,
    "id" : aws_kms_key.terraform_state.id,
    "alias" : aws_kms_alias.terraform_state.name,
    "alias_arn" : aws_kms_alias.terraform_state.arn,
  }
}
