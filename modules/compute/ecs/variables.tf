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

variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "cluster_configuration" {
  description = "ECS cluster configuration."
  type = object({
    execute_command_configuration = object({
      logging = string
    })
    service_connect_defaults = object({
      namespace = string
    })
  })
  default = null
}

variable "setting" {
  description = "Cluster settings."
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
  default     = []
}

variable "enable_fargate_capacity_providers" {
  description = "Enable FARGATE and FARGATE_SPOT capacity providers."
  type        = bool
  default     = true
}

variable "autoscaling_configuration" {
  description = "Auto Scaling Group configuration for EC2 capacity."
  type = object({
    min_size      = number
    max_size      = number
    desired_size  = number
    instance_type = string
    ami_id        = string
    image_id      = string
  })
  default = null
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for container logs."
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_retention_days" {
  description = "CloudWatch log group retention days."
  type        = number
  default     = 90
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption."
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "service_definition" {
  description = "ECS service definition."
  type = object({
    task_definition = string
    desired_count   = number
    launch_type     = string
    network_configuration = object({
      subnets          = list(string)
      security_groups  = list(string)
      assign_public_ip = bool
    })
    load_balancer = object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    })
  })
  default = null
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
