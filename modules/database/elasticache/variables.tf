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
  description = "Name for the ElastiCache cluster."
  type        = string
}

variable "engine" {
  description = "Cache engine (memcached or redis)."
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "Engine version."
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Cache node type (e.g., cache.t3.micro)."
  type        = string
}

variable "num_cache_nodes" {
  description = "Number of cache nodes."
  type        = number
  default     = 2
}

variable "parameter_group_name" {
  description = "Cache parameter group name."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
  default     = []
}

variable "port" {
  description = "Port number."
  type        = number
  default     = 6379
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ for Redis cluster."
  type        = bool
  default     = false
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover for Redis cluster."
  type        = bool
  default     = false
}

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest."
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable transit encryption."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption."
  type        = string
  default     = ""
}

variable "snapshot_retention_limit" {
  description = "Snapshot retention limit in days."
  type        = number
  default     = 7
}

variable "snapshot_name" {
  description = "Snapshot name for restoration."
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
