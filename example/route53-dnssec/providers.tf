# Let's say this is our default region

locals {
  aws_region = "eu-west-2"
}

provider "aws" {
  region = local.aws_region
}

# For Route 53-related resources, we must use the us-east-1 region.
# This is required because some Route 53 features,
# such as DNSSEC with KMS, only work in us-east-1.

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
