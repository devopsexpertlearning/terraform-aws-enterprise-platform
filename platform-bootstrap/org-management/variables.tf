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
  default     = ""
}

variable "cost_center" {
  description = "The cost center."
  type        = string
  default     = "UNKNOWN"
}

variable "organization_unit_name" {
  description = "Name of the organizational unit."
  type        = string
}

variable "parent_id" {
  description = "Parent Organizational Unit ID or Root ID."
  type        = string
  default     = ""
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
