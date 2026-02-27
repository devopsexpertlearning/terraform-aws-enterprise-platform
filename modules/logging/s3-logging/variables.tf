variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "The environment context."
  type        = string
}

variable "owner" {
  description = "The owner/team responsible."
  type        = string
}

variable "cost_center" {
  description = "The cost center."
  type        = string
  default     = "UNKNOWN"
}

variable "bucket_name" {
  description = "Name for the logging bucket."
  type        = string
}

variable "target_bucket_arn" {
  description = "ARN of target bucket for logging (optional - creates new if empty)."
  type        = string
  default     = ""
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket."
  type = list(object({
    id              = string
    enabled         = bool
    expiration_days = number
  }))
  default = []
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
  }
}
