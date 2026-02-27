variable "project_name" {
  description = "Name of the project - used for resource naming."
  type        = string
}

variable "environment" {
  description = "The environment context."
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

variable "aws_region" {
  description = "The AWS region to deploy to."
  type        = string
  default     = "us-east-1"
}

variable "enable_access_logging" {
  description = "Enable access logging for S3 bucket."
  type        = bool
  default     = true
}

variable "force_destroy_bucket" {
  description = "Force destroy S3 bucket on deletion."
  type        = bool
  default     = false
}

variable "create_dynamodb_lock_table" {
  description = "Create DynamoDB table for legacy state locking. Not required when using S3 backend lockfile."
  type        = bool
  default     = false
}
