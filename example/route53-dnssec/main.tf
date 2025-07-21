resource "aws_route53_zone" "myexample_com" {
  name = "myexample.com"

  provider = aws.use1
}

module "dnssec_example_com" {
  source = "../../module/route53-dnssec"

  domain         = aws_route53_zone.myexample_com.name
  hosted_zone_id = aws_route53_zone.myexample_com.id

  depends_on = [
    aws_route53_zone.myexample_com,
  ]

  providers = { aws = aws.use1 }
}
