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

variable "table_name" {
  description = "The logical name of the DynamoDB table."
  type        = string
}

variable "hash_key" {
  description = "Partition key attribute name."
  type        = string
}

variable "range_key" {
  description = "Sort key attribute name (optional)."
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attributes specifying name and type (S, N, B)."
  type = list(object({
    name = string
    type = string
  }))
}

variable "billing_mode" {
  description = "Billing mode (PAY_PER_REQUEST or PROVISIONED)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units (required for PROVISIONED mode)."
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (required for PROVISIONED mode)."
  type        = number
  default     = 5
}

variable "point_in_time_recovery_enabled" {
  description = "Enable Point-in-Time Recovery."
  type        = bool
  default     = true
}

variable "ttl_enabled" {
  description = "Enable TTL for the table."
  type        = bool
  default     = false
}

variable "ttl_attribute" {
  description = "TTL attribute name."
  type        = string
  default     = "ExpiresAt"
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "kms_key_arn" {
  description = "KMS key ARN for server-side encryption."
  type        = string
  default     = ""
}

variable "table_class" {
  description = "Table class (STANDARD, STANDARD_INFREQUENT_ACCESS)."
  type        = string
  default     = "STANDARD"
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes."
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    projection_type    = string
    read_capacity      = number
    write_capacity     = number
    non_key_attributes = list(string)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes."
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = []
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
