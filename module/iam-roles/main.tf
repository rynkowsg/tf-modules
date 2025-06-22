# --------------------
#  IAM roles
# --------------------

resource "aws_iam_role" "role" {
  for_each = { for idx, r in var.roles : r.name => r }

  name = each.value.name
  assume_role_policy = each.value.assume_role_policy
}

# --------------------------
#  Inline IAM role policies
# --------------------------

locals {
  inline_policies = flatten([
    for r in var.roles : [
      for ip in r.inline_policy: {
        role_name: r.name
        inline_policy_name: ip.name
        inline_policy_content: ip.content
      }
    ]
  ])
}

resource "aws_iam_role_policy" "inline_policy" {
  for_each = { for idx, ip in local.inline_policies: "${ip["role_name"]}--${ip["inline_policy_name"]}" => ip }
  role = each.value["role_name"]
  name = each.value["inline_policy_name"]
  policy = each.value["inline_policy_content"]
}

# ------------------------------
#  IAM roles policy attachments
# ------------------------------

locals {
  policy_attachments = flatten([
    for r in var.roles : [
      for rarn in r.attached_policy_arns: {
        role_name: r.name
        arn: rarn
      }
    ]
  ])
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each   = { for idx, pa in local.policy_attachments: "${pa["role_name"]}--${basename(pa["arn"])}" => pa }
  role       = each.value["role_name"]
  policy_arn = each.value["arn"]
}
