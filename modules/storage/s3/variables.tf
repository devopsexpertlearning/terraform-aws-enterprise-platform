variable "project_name" {}
variable "environment" {}

variable "bucket_name_suffix" {
  type        = string
  description = "Unique suffix for the bucket"
}

variable "kms_key_arn" {
  type        = string
  description = "CMK ARN to enforce server-side encryption"
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "lifecycle_rules_enabled" {
  type    = bool
  default = true
}

variable "transition_to_ia_days" {
  type    = number
  default = 90
}
