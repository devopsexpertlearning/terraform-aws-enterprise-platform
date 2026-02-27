variable "role_name" {
  type        = string
  description = "Name of the IAM Role"
}

variable "assume_role_policy" {
  type        = string
  description = "JSON policy for the trust relationship / assume role policy"
}

variable "permissions_boundary_arn" {
  type        = string
  description = "ARN of the Enterprise Permissions Boundary policy. THIS IS REQUIRED."
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "List of managed policy ARNs to attach"
  default     = []
}

variable "inline_policies" {
  type        = map(string)
  description = "Map of inline policy names to their JSON content"
  default     = {}
}

variable "project_name" {}
variable "environment" {}
