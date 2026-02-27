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
  description = "Name for the Auto Scaling Group."
  type        = string
}

variable "launch_template_id" {
  description = "The ID of the launch template."
  type        = string
}

variable "launch_template_version" {
  description = "Version of the launch template to use. Use $Latest for latest."
  type        = string
  default     = "$Latest"
}

variable "vpc_zone_identifier" {
  description = "List of subnet IDs for the ASG."
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of instances."
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances."
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances."
  type        = number
  default     = null
}

variable "default_cooldown" {
  description = "Cooldown period between scaling activities."
  type        = number
  default     = 300
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)."
  type        = string
  default     = "ELB"
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance launch before starting health checks."
  type        = number
  default     = 300
}

variable "termination_policies" {
  description = "Termination policies for instances."
  type        = list(string)
  default     = ["Default"]
}

variable "suspended_processes" {
  description = "Processes to suspend."
  type        = list(string)
  default     = []
}

variable "placement_group" {
  description = "Placement group for instances."
  type        = string
  default     = ""
}

variable "enable_metrics_collection" {
  description = "Enable metrics collection."
  type        = bool
  default     = true
}

variable "metrics_granularity" {
  description = "Metrics granularity (1Minute, 5Minute, 15Minute, 1Hour, 6Hour, 1Day, 3Month, 1Year)."
  type        = string
  default     = "1Minute"
}

variable "target_group_arns" {
  description = "List of ALB target group ARNs to attach."
  type        = list(string)
  default     = []
}

variable "protect_from_scale_in" {
  description = "Protect instances from scale in."
  type        = bool
  default     = false
}

variable "max_instance_lifetime" {
  description = "Maximum instance lifetime in seconds."
  type        = number
  default     = null
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
