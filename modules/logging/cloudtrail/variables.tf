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
  description = "Name for the CloudTrail."
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs."
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix."
  type        = string
  default     = "cloudtrail/"
}

variable "include_global_service_events" {
  description = "Include global service events."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Create multi-region trail."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption."
  type        = string
}

variable "enable_log_file_validation" {
  description = "Enable log file validation."
  type        = bool
  default     = true
}

variable "manage_bucket_policy" {
  description = "Whether this module should manage the CloudTrail-required S3 bucket policy."
  type        = bool
  default     = true
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
