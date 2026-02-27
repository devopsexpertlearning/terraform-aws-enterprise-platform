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
  description = "Name for the target group."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "port" {
  description = "Port for the target group."
  type        = number
  default     = 80
}

variable "protocol" {
  description = "Protocol (TCP, HTTP, HTTPS)."
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type (instance, ip, lambda)."
  type        = string
  default     = "instance"
}

variable "health_check_path" {
  description = "Health check path."
  type        = string
  default     = "/"
}

variable "health_check_interval_seconds" {
  description = "Health check interval."
  type        = number
  default     = 30
}

variable "health_check_timeout_seconds" {
  description = "Health check timeout."
  type        = number
  default     = 5
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count."
  type        = number
  default     = 3
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count."
  type        = number
  default     = 3
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
