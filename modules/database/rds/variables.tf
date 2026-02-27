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

variable "identifier" {
  description = "Identifier for the RDS instance."
  type        = string
}

variable "engine" {
  description = "Database engine (postgres, mysql, mariadb, oracle-se, oracle-se1, sqlserver-se, sqlserver-ex, sqlserver-web)."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
}

variable "instance_class" {
  description = "DB instance class (e.g., db.t3.medium)."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
}

variable "max_allocated_storage" {
  description = "Maximum storage allocation in GB for autoscaling."
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "Storage type (standard, gp2, gp3, io1, io2)."
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "IOPS for io1, io2, or gp3 storage."
  type        = number
  default     = 3000
}

variable "storage_throughput" {
  description = "Throughput for gp3 storage in MB/s."
  type        = number
  default     = 125
}

variable "db_name" {
  description = "Name of the initial database."
  type        = string
}

variable "username" {
  description = "Master username."
  type        = string
}

variable "password_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the database password."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for database encryption."
  type        = string
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

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (e.g., 03:00-04:00)."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (e.g., mon:04:00-mon:05:00)."
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Make the DB publicly accessible. NOT recommended for production."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier if skip_final_snapshot is false."
  type        = string
  default     = ""
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch logs to export."
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "performance_insights_kms_key_id" {
  description = "KMS key for Performance Insights encryption."
  type        = string
  default     = ""
}

variable "ca_cert_identifier" {
  description = "CA certificate identifier."
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "parameter_group_name" {
  description = "DB parameter group name."
  type        = string
  default     = ""
}

variable "option_group_name" {
  description = "DB option group name."
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
