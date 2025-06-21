output "bucket" {
  value = {
    "arn" : aws_s3_bucket.terraform_state.arn,
    "name" : aws_s3_bucket.terraform_state.bucket,
  }
}
