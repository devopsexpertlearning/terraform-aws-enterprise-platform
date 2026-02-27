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

variable "zone_name" {
  description = "The name of the hosted zone."
  type        = string
}

variable "comment" {
  description = "Comment for the hosted zone."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC ID to associate with a private hosted zone."
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Force destroy the hosted zone."
  type        = bool
  default     = false
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
