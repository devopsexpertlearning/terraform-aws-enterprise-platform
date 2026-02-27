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
  description = "Name for the EBS volume."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the volume."
  type        = string
}

variable "size" {
  description = "Size of the volume in GiB."
  type        = number
  default     = 100
}

variable "type" {
  description = "Type of the volume (gp2, gp3, io1, io2, st1, sc1)."
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "IOPS for io1, io2, or gp3."
  type        = number
  default     = 3000
}

variable "throughput" {
  description = "Throughput for gp3 in MiB/s."
  type        = number
  default     = 125
}

variable "encrypted" {
  description = "Enable encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption."
  type        = string
  default     = ""
}

variable "snapshot_id" {
  description = "Snapshot ID to create volume from."
  type        = string
  default     = ""
}

variable "multi_attach_enabled" {
  description = "Enable multi-attach for io1/io2."
  type        = bool
  default     = false
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
