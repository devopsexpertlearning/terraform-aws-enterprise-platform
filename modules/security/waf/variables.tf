variable "project_name" {
  type        = string
  description = "Project name for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier."
}

variable "waf_name" {
  type        = string
  description = "Name for the WAF Web ACL."
}

variable "scope" {
  type        = string
  description = "Scope of the WAF. Valid values: REGIONAL (for ALB/API GW) or CLOUDFRONT."
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope must be REGIONAL or CLOUDFRONT."
  }
}

variable "associated_resource_arn" {
  type        = string
  description = "ARN of the ALB or API Gateway to associate with the WAF. Set to null if not associating immediately."
  default     = null
}

variable "rate_limit" {
  type        = number
  description = "Maximum number of requests allowed in a 5-minute period from a single IP."
  default     = 2000
}
