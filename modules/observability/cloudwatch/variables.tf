variable "project_name" {
  type        = string
  description = "Project name for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier."
}

variable "log_group_name" {
  type        = string
  description = "Name of the CloudWatch Log Group."
}

variable "retention_in_days" {
  type        = number
  description = "Number of days to retain log events."
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.retention_in_days)
    error_message = "retention_in_days must be a valid CloudWatch retention period."
  }
}

variable "kms_key_arn" {
  description = "Enterprise CMK ARN to encrypt CloudWatch logs at rest."
  default     = ""
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
