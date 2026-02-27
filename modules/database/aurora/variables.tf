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

variable "cluster_identifier" {
  description = "Identifier for the Aurora cluster."
  type        = string
}

variable "engine" {
  description = "Aurora engine (aurora, aurora-mysql, aurora-postgresql)."
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Aurora engine version."
  type        = string
}

variable "database_name" {
  description = "Name of the initial database."
  type        = string
}

variable "master_username" {
  description = "Master username."
  type        = string
}

variable "password_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the database password."
  type        = string
}

variable "instance_class" {
  description = "DB instance class (e.g., db.t3.medium)."
  type        = string
}

variable "instances" {
  description = "Number of Aurora instances."
  type = object({
    writer = number
    reader = number
  })
  default = {
    writer = 1
    reader = 1
  }
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "storage_encrypted" {
  description = "Enable storage encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for storage encryption."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
  default     = []
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window."
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window."
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier."
  type        = string
  default     = ""
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch logs to export."
  type        = list(string)
  default     = ["postgresql"]
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "serverlessv2_scaling_configuration" {
  description = "Serverless v2 scaling configuration."
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "global_cluster_identifier" {
  description = "Global cluster identifier for cross-region replication."
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
