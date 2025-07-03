// label

variable "label_full" {
  description = "Optional override for the full resource label. If provided, this value will be used directly instead of composing the label from other parameters like namespace, name, stage, etc."
  type        = string
  default     = null
  validation {
    condition     = var.label_full != ""
    error_message = "label_full must not be an empty string"
  }
}

variable "label_namespace" {
  description = "A short (3–4 letter) abbreviation of the company or team name, used to ensure globally unique names for resources like S3 buckets."
  type        = string
  default     = null
  validation {
    condition     = var.label_namespace != ""
    error_message = "label_namespace must not be an empty string"
  }
}

variable "label_region" {
  description = "Short abbreviation for the AWS region hosting the resource, or 'gbl' for global resources like IAM roles."
  type        = string
  default     = null
  validation {
    condition     = var.label_region != ""
    error_message = "label_region must not be an empty string"
  }
}

variable "label_stage" {
  description = "The deployment stage or environment the resource belongs to, such as dev, test, staging, prod, or shared (for shared, non-stage-specific infra like security or identity)."
  type        = string
  default     = null
  validation {
    condition     = var.label_stage != ""
    error_message = "label_stage must not be an empty string"
  }
}

variable "label_name" {
  description = "The name of the application or component that owns this resource."
  type        = string
  default     = null
  validation {
    condition     = var.label_name != ""
    error_message = "label_name must not be an empty string"
  }
}

variable "label_extras" {
  description = "Additional elements to include in the generated label (e.g., 'workers' or 'cluster')."
  type        = list(string)
  default     = []
}

// common

variable "tags" {
  type    = map(string)
  default = {}
}

// bucket specific

variable "bucket_policy" {
  type    = string
  default = null
}

variable "bucket_kms_key_policy" {
  type    = string
  default = null
}

variable "bucket_key_enabled" {
  type    = bool
  default = true
}

variable "bucket_force_destroy" {
  type    = bool
  default = false
}
