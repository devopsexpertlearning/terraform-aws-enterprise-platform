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
  description = "Name for the EC2 instance."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The instance type (e.g., t3.medium)."
  type        = string
  default     = "t3.medium"
}

variable "subnet_id" {
  description = "The subnet ID to deploy the instance in. Must be a private subnet for secure deployment."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to attach to the instance."
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "The IAM instance profile name to attach to the instance."
  type        = string
  default     = ""
}

variable "user_data_base64" {
  description = "Base64-encoded user data script. Use this for secure, non-interactive provisioning."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script (plain text). Will be base64 encoded automatically."
  type        = string
  default     = null
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

variable "kms_key_arn" {
  description = "KMS key ARN for root volume encryption."
  type        = string
  default     = ""
}

variable "enable_ebs_optimized" {
  description = "Enable EBS optimization for the instance."
  type        = bool
  default     = true
}

variable "enable_instance_metadata_service" {
  description = "Enable the Instance Metadata Service."
  type        = bool
  default     = true
}

variable "instance_metadata_tokens" {
  description = "IMDSv2 tokens required (required for secure IMDS)."
  type        = string
  default     = "required"
}

variable "instance_metadata_hop_limit" {
  description = "IMDSv2 hop limit."
  type        = number
  default     = 1
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address. NOT recommended for production."
  type        = bool
  default     = false
}

variable "tenancy" {
  description = "Tenancy of the instance (default, dedicated, host)."
  type        = string
  default     = "default"
}

variable "termination_protection" {
  description = "Enable termination protection."
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "additional_ebs_volumes" {
  description = "Additional EBS volumes to attach."
  type = map(object({
    device_name = string
    size        = number
    type        = string
    kms_key_arn = string
  }))
  default = {}
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
