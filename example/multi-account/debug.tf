# locals {
#   debug_data = {
#     account_id: local.aws_account_id
#     root_id: data.aws_organizations_organization.this.roots[0].id
#     accounts_yaml_path: local.accounts_yaml_path
#     ou: module.multi_account.ou
#     account: module.multi_account.account
#   }
# }
#
# output "debug_data" {
#   value = local.debug_data
# }
#
# output "module_debug_data" {
#   value = module.multi_account.account
# }
