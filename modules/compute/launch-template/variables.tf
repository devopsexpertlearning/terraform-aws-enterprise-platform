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
  description = "Name for the launch template."
  type        = string
}

variable "image_id" {
  description = "The AMI ID to use for instances launched from this template."
  type        = string
}

variable "instance_type" {
  description = "The instance type (e.g., t3.medium)."
  type        = string
  default     = "t3.medium"
}

variable "iam_instance_profile" {
  description = "The IAM instance profile ARN or name."
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "Base64-encoded user data script."
  type        = string
  default     = null
}

variable "key_name" {
  description = "The key pair name. Leave empty for no key pair (SSM Session Manager recommended)."
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Size of the root volume in GB."
  type        = number
  default     = 50
}

variable "root_volume_type" {
  description = "Type of the root volume (gp2, gp3, io1, io2)."
  type        = string
  default     = "gp3"
}

variable "root_volume_iops" {
  description = "IOPS for the root volume (for io1, io2, gp3)."
  type        = number
  default     = 3000
}

variable "root_volume_throughput" {
  description = "Throughput for the root volume (for gp3)."
  type        = number
  default     = 125
}

variable "kms_key_arn" {
  description = "KMS key ARN for root volume encryption."
  type        = string
  default     = ""
}

variable "enable_ebs_optimized" {
  description = "Enable EBS optimization."
  type        = bool
  default     = true
}

variable "metadata_options" {
  description = "IMDS configuration."
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = true
}

variable "instance_market_options" {
  description = "Spot market options. Leave empty for on-demand."
  type = object({
    market_type = string
    spot_options = object({
      max_price                      = string
      instance_interruption_behavior = string
    })
  })
  default = null
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
