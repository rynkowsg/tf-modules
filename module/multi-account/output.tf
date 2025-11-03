locals {
  accounts_by_key = merge(
    local.l1_accounts_created_by_key,
    local.l2_accounts_created_by_key,
    local.l3_accounts_created_by_key,
    local.l4_accounts_created_by_key,
    local.l5_accounts_created_by_key,
  )
  accounts_by_name = merge(
    local.l1_accounts_created_by_name,
    local.l2_accounts_created_by_name,
    local.l3_accounts_created_by_name,
    local.l4_accounts_created_by_name,
    local.l5_accounts_created_by_name,
  )
  ous_by_key = merge(
    local.l1_ous_created_by_key,
    local.l2_ous_created_by_key,
    local.l3_ous_created_by_key,
    local.l4_ous_created_by_key,
    local.l5_ous_created_by_key,
  )
  ous_by_name = merge(
    local.l1_ous_created_by_name,
    local.l2_ous_created_by_name,
    local.l3_ous_created_by_name,
    local.l4_ous_created_by_name,
    local.l5_ous_created_by_name,
  )
}

# deprecated
output "account" {
  value     = local.accounts_by_key
  sensitive = true # to hide account ids
}

# deprecated
output "ou" {
  value     = local.ous_by_key
  sensitive = true # to hide account ids
}

output "account_by_key" {
  value     = local.accounts_by_key
  sensitive = true # to hide account ids
}

output "account_by_name" {
  value     = local.accounts_by_name
  sensitive = true # to hide account ids
}

output "ou_by_key" {
  value     = local.ous_by_key
  sensitive = true # to hide account ids
}

output "ou_by_name" {
  value     = local.ous_by_name
  sensitive = true # to hide account ids
}
