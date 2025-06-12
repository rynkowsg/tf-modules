output "bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The S3 bucket created to store the Terraform state."
}
