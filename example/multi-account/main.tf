locals {
  accounts_yaml_path = abspath("${path.module}/accounts.yml")
}

module "multi_account" {
  source             = "../../module/multi-account"
  accounts_yaml_path = local.accounts_yaml_path
}
