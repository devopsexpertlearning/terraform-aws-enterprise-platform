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
  description = "Name for the EFS file system."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for mount targets."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
  default     = []
}

variable "encrypted" {
  description = "Enable encryption at rest."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption."
  type        = string
  default     = ""
}

variable "throughput_mode" {
  description = "Throughput mode (bursting or provisioned)."
  type        = string
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput in MiB/s."
  type        = number
  default     = 0
}

variable "performance_mode" {
  description = "Performance mode (generalPurpose or maxIO)."
  type        = string
  default     = "generalPurpose"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "enable_access_point" {
  description = "Enable EFS access point."
  type        = bool
  default     = false
}

variable "posix_user_gid" {
  description = "POSIX user GID."
  type        = number
  default     = 1000
}

variable "posix_user_uid" {
  description = "POSIX user UID."
  type        = number
  default     = 1000
}

variable "access_point_path" {
  description = "Access point root directory path."
  type        = string
  default     = "/"
}

variable "access_point_permissions" {
  description = "Access point root directory permissions."
  type        = string
  default     = "755"
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
