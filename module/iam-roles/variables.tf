variable "roles" {
  type = list(object({
    name: string
    assume_role_policy: string
    inline_policy: list(object({
      name = string
      content = string
    }))
    attached_policy_arns = list(string)
  }))
  default = []
}
