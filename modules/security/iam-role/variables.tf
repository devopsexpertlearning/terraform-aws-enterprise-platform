variable "project_name" {
  description = "Name of the project - used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "The environment context (e.g., dev, staging, prod)."
  type        = string
}

variable "owner" {
  description = "The owner/team responsible for this infrastructure."
  type        = string
}

variable "cost_center" {
  description = "The cost center for billing purposes."
  type        = string
  default     = "UNKNOWN"
}

variable "name" {
  description = "Name for the IAM role."
  type        = string
}

variable "assume_role_policy" {
  description = "JSON assume role policy document."
  type        = string
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Inline policy document (JSON)."
  type        = string
  default     = ""
}

variable "inline_policy_name" {
  description = "Name for the inline policy."
  type        = string
  default     = ""
}

variable "path" {
  description = "Path for the IAM role."
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "Permissions boundary policy ARN."
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds."
  type        = number
  default     = 3600
}

variable "force_detach_policy" {
  description = "Force detach policies on deletion."
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}
