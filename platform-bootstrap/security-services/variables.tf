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

variable "cloudtrail_log_bucket_name" {
  description = "Name for CloudTrail S3 logging bucket. If empty, will be created."
  type        = string
  default     = ""
}

variable "enable_guardduty" {
  description = "Enable GuardDuty in the account."
  type        = bool
  default     = true
}

variable "guardduty_detector_options" {
  description = "GuardDuty detector configuration options."
  type = object({
    enable = bool
  })
  default = {
    enable = true
  }
}
