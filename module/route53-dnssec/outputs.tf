# output "debug" {
#   value = {
#     aws_kms_key : aws_kms_key.default
#     aws_kms_alias : aws_kms_alias.default
#     aws_route53_key_signing_key : aws_route53_key_signing_key.default
#     aws_route53_hosted_zone_dnssec: aws_route53_hosted_zone_dnssec.default
#   }
# }

output "kms_key" {
  value = aws_kms_key.default
}

output "aws_kms_alias" {
  value = aws_kms_alias.default
}

output "ksk" {
  value = aws_route53_key_signing_key.default
}

output "dnssec" {
  value = aws_route53_hosted_zone_dnssec.default
}
