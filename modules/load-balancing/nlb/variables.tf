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
  description = "Name for the NLB."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Create internal NLB."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing."
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "Target group ARN."
  type        = string
  default     = ""
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
