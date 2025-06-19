terraform {
  # https://releases.hashicorp.com/terraform
  # https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
  required_version = "= 1.12.2"
}

terraform {
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}
