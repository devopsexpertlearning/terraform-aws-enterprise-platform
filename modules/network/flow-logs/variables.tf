variable "project_name" {
  description = "Name of the project - used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "The environment context (e.g., dev, staging, prod)."
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

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "log_destination_arn" {
  description = "S3 bucket ARN for VPC Flow Logs."
  type        = string
  default     = ""
}

variable "log_destination_type" {
  description = "Destination type (cloud-watch-logs or s3)."
  type        = string
  default     = "s3"
}
