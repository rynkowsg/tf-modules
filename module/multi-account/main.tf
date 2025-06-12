# ------------------------------------------------------------------------------
# OUs and accounts
# ------------------------------------------------------------------------------

locals {
  root_id      = var.aws_root_id
  accounts_yml = yamldecode(file(var.accounts_yaml_path))
}

# LEVEL 0

locals {
  root_node     = local.accounts_yml["root"]
  root_children = local.root_node["children"]
}

# LEVEL 1

locals {
  l1_ous_list = [
    for root_child in local.root_children : merge({ children = [], parent = { name = "root", id = local.root_id } }, root_child)
    if root_child["type"] == "ou"
  ]
  l1_ous = { for ou in local.l1_ous_list : ou["name"] => ou }

  l1_account_list = [
    for root_child in local.root_children :
    merge({ parent = { name = "root", id = local.root_id } }, root_child)
    if root_child["type"] == "account"
  ]
  l1_accounts = { for account in local.l1_account_list : account["name"] => account }
}

resource "aws_organizations_organizational_unit" "ou_l1" {
  for_each  = local.l1_ous
  name      = each.value["name"]
  parent_id = each.value["parent"]["id"]
}

resource "aws_organizations_account" "account_l1" {
  for_each  = local.l1_accounts
  name      = each.value["name"]
  email     = each.value["email"]
  parent_id = each.value["parent"]["id"]
}

locals {
  l1_ous_created      = { for o in aws_organizations_organizational_unit.ou_l1 : o.name => merge(local.l1_ous[o.name], { id = o.id }) }
  l1_accounts_created = { for a in aws_organizations_account.account_l1 : a.name => merge(local.l1_accounts[a.name], { id = a.id }) }
}

# LEVEL 2

locals {
  l2_ous_list = flatten(
    [
      for ou in local.l1_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ children = [], parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "ou"
      ]
    ]
  )
  l2_ous = { for ou in local.l2_ous_list : ou["name"] => ou }

  l2_accounts_list = flatten(
    [
      for ou in local.l1_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "account"
      ]
    ]
  )
  l2_accounts = { for account in local.l2_accounts_list : account["name"] => account }

  #  l2_ous = {for ou in local.l2_yml_ous: ou[local.key_name] => merge(ou, {parent = local.l1_ous_created[ou[local.key_name]]})}
}

resource "aws_organizations_organizational_unit" "ou_l2" {
  for_each  = local.l2_ous
  name      = each.value["name"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l1
  ]
}

resource "aws_organizations_account" "account_l2" {
  for_each  = local.l2_accounts
  name      = each.value["name"]
  email     = each.value["email"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l1
  ]
}

locals {
  l2_ous_created      = { for o in aws_organizations_organizational_unit.ou_l2 : o.name => merge(local.l2_ous[o.name], { id = o.id }) }
  l2_accounts_created = { for a in aws_organizations_account.account_l2 : a.name => merge(local.l2_accounts[a.name], { id = a.id }) }
}

# LEVEL 3

locals {
  l3_ous_list = flatten(
    [
      for ou in local.l2_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ children = [], parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "ou"
      ]
    ]
  )
  l3_ous = { for ou in local.l3_ous_list : ou["name"] => ou }

  l3_accounts_list = flatten(
    [
      for ou in local.l2_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "account"
      ]
    ]
  )
  l3_accounts = { for account in local.l3_accounts_list : account["name"] => account }
}

resource "aws_organizations_organizational_unit" "ou_l3" {
  for_each  = local.l3_ous
  name      = each.value["name"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l2
  ]
}

resource "aws_organizations_account" "account_l3" {
  for_each  = local.l3_accounts
  name      = each.value["name"]
  email     = each.value["email"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l2
  ]
}

locals {
  l3_ous_created      = { for o in aws_organizations_organizational_unit.ou_l3 : o.name => merge(local.l3_ous[o.name], { id = o.id }) }
  l3_accounts_created = { for a in aws_organizations_account.account_l3 : a.name => merge(local.l3_accounts[a.name], { id = a.id }) }
}

# LEVEL 4

locals {
  l4_ous_list = flatten(
    [
      for ou in local.l3_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ children = [], parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "ou"
      ]
    ]
  )
  l4_ous = { for ou in local.l4_ous_list : ou["name"] => ou }

  l4_accounts_list = flatten(
    [
      for ou in local.l3_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "account"
      ]
    ]
  )
  l4_accounts = { for account in local.l4_accounts_list : account["name"] => account }
}

resource "aws_organizations_organizational_unit" "ou_l4" {
  for_each  = local.l4_ous
  name      = each.value["name"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l3
  ]
}

resource "aws_organizations_account" "account_l4" {
  for_each  = local.l4_accounts
  name      = each.value["name"]
  email     = each.value["email"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l3
  ]
}

locals {
  l4_ous_created      = { for o in aws_organizations_organizational_unit.ou_l4 : o.name => merge(local.l4_ous[o.name], { id = o.id }) }
  l4_accounts_created = { for a in aws_organizations_account.account_l4 : a.name => merge(local.l4_accounts[a.name], { id = a.id }) }
}

# LEVEL 5

locals {
  l5_ous_list = flatten(
    [
      for ou in local.l4_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ children = [], parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "ou"
      ]
    ]
  )
  l5_ous = { for ou in local.l5_ous_list : ou["name"] => ou }

  l5_accounts_list = flatten(
    [
      for ou in local.l4_ous_created :
      [
        for ou_child in ou["children"] :
        merge({ parent = { name = ou["name"], id = ou["id"] } }, ou_child)
        if ou_child["type"] == "account"
      ]
    ]
  )
  l5_accounts = { for account in local.l5_accounts_list : account["name"] => account }
}

resource "aws_organizations_organizational_unit" "ou_l5" {
  for_each  = local.l5_ous
  name      = each.value["name"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l3
  ]
}

resource "aws_organizations_account" "account_l5" {
  for_each  = local.l5_accounts
  name      = each.value["name"]
  email     = each.value["email"]
  parent_id = each.value["parent"]["id"]
  depends_on = [
    aws_organizations_organizational_unit.ou_l4
  ]
}

locals {
  l5_ous_created      = { for o in aws_organizations_organizational_unit.ou_l5 : o.name => merge(local.l5_ous[o.name], { id = o.id }) }
  l5_accounts_created = { for a in aws_organizations_account.account_l5 : a.name => merge(local.l5_accounts[a.name], { id = a.id }) }
}

###################

locals {
  accounts = merge(
    local.l1_accounts_created,
    local.l2_accounts_created,
    local.l3_accounts_created,
    local.l4_accounts_created,
    local.l5_accounts_created,
  )
  ous = merge(
    local.l1_ous_created,
    local.l2_ous_created,
    local.l3_ous_created,
    local.l4_ous_created,
    local.l5_ous_created,
  )
}

output "account" {
  value     = local.accounts
  sensitive = true # to hide account ids
}

output "ou" {
  value     = local.ous
  sensitive = true # to hide account ids
}
