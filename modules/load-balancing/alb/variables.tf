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

variable "name" {
  description = "Name for the ALB."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Create an internal-facing ALB."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs."
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "Prefix for access logs."
  type        = string
  default     = "alb-logs"
}

variable "enable_access_logs" {
  description = "Enable access logs."
  type        = bool
  default     = true
}

variable "default_ssl_certificate_arn" {
  description = "ARN of the default SSL certificate in ACM."
  type        = string
  default     = ""
}

variable "idle_timeout" {
  description = "Idle timeout in seconds."
  type        = number
  default     = 60
}

variable "enable_http2" {
  description = "Enable HTTP/2."
  type        = bool
  default     = true
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid header fields."
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing."
  type        = bool
  default     = true
}

variable "waf_acl_arn" {
  description = "WAF ACL ARN to associate with the ALB."
  type        = string
  default     = ""
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
