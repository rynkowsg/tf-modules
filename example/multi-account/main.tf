
locals {
  aws_region = "eu-west-2"
}

provider "aws" {
  region = local.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id     = data.aws_caller_identity.current.account_id
  accounts_yaml_path = abspath("${path.module}/accounts.yml")
}

data "aws_organizations_organization" "this" {}

module "multi_account" {
  source             = "../../module/multi-account"
  accounts_yaml_path = local.accounts_yaml_path
  aws_root_id        = data.aws_organizations_organization.this.roots[0].id
}

# account map
output "account" {
  value = module.multi_account.account
}

# ou map
output "ou" {
  value = module.multi_account.ou
}
