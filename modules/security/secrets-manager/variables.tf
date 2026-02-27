variable "project_name" {
  type        = string
  description = "Project name for resource naming and tagging."
}

variable "environment" {
  type        = string
  description = "Environment identifier."
}

variable "secret_name" {
  type        = string
  description = "The friendly name of the secret."
}

variable "description" {
  type        = string
  description = "Description of the secret."
  default     = "Managed by Terraform"
}

variable "kms_key_arn" {
  type        = string
  description = "Enterprise CMK ARN to encrypt the secret."
}

variable "secret_string" {
  type        = string
  description = "The secret value to store. For structured data, pass a JSON string."
  sensitive   = true
  default     = null
}

variable "recovery_window_in_days" {
  type        = number
  description = "Number of days that AWS Secrets Manager waits before deleting a secret."
  default     = 30

  validation {
    condition     = var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30
    error_message = "Recovery window must be between 7 and 30 days."
  }
}

variable "owner" {
  description = "The owner/team responsible for this infrastructure."
  type        = string
  default     = ""
}

variable "cost_center" {
  description = "The cost center for billing purposes."
  type        = string
  default     = "UNKNOWN"
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
