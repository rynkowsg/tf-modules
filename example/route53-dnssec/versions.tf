terraform {
  # https://releases.hashicorp.com/terraform
  # https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
  required_version = "= 1.12.2"
}

terraform {
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      # https://github.com/hashicorp/terraform-provider-aws/releases
      source  = "hashicorp/aws"
      version = "6.4.0"
    }
  }
}
