variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

// label

variable "label_namespace" {
  description = "A short (3-4 letters) abbreviation of the company name, to ensure globally unique IDs for things like S3 buckets"
  type        = string
  default     = null
}

variable "label_region" {
  description = "A short abbreviation for the AWS region hosting the resource, or gbl for resources like IAM roles that have no region"
  type        = string
  default     = null
}

variable "label_stage" {
  description = "The name or role of the account the resource is for, such as dev, test, prod, security, identity."
  type        = string
  default     = null
}

variable "label_name" {
  description = "The name of the component that owns the resource"
  type        = string
}

variable "label_extras" {
  description = "ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`"
  type        = list(string)
  default     = []
}

// common

variable "tags" {
  type    = map(string)
  default = {}
}

// S3 specific

variable "bucket_force_destroy" {
  type    = bool
  default = false
}
