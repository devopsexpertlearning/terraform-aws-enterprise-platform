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

variable "name" {
  description = "Name for the IAM policy."
  type        = string
}

variable "path" {
  description = "Path for the IAM policy."
  type        = string
  default     = "/"
}

variable "description" {
  description = "Description of the policy."
  type        = string
  default     = "IAM policy managed by Terraform"
}

variable "policy" {
  description = "JSON policy document."
  type        = string
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
  }, var.tags)
}
