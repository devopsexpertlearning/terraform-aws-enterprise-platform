variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "environment must be one of: dev, uat, prod."
  }
}

variable "owner" {
  description = "Owning team or person."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag value."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets."
  type        = list(string)
}

variable "isolated_subnet_cidrs" {
  description = "CIDRs for isolated subnets."
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "Availability zones to use."
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "If true, creates one NAT gateway for all private subnets."
  type        = bool
  default     = true
}

variable "enable_customer_managed_kms" {
  description = "Enable a customer-managed KMS key for EC2 root volume encryption."
  type        = bool
  default     = false
}

variable "kms_key_user_arns" {
  description = "Principal ARNs allowed to use the customer-managed KMS key."
  type        = list(string)
  default     = []
}

variable "workload_name" {
  description = "Logical workload name used in resource names."
  type        = string
  default     = "app"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 50
}

variable "termination_protection" {
  description = "Enable EC2 termination protection."
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = true
}

variable "ssh_ingress_cidrs" {
  description = "Administrative CIDRs allowed SSH access. Keep empty unless needed."
  type        = list(string)
  default     = []
}

variable "additional_ebs_volumes" {
  description = "Additional EBS volumes to attach to instance."
  type = map(object({
    device_name = string
    size        = number
    type        = string
    kms_key_arn = string
  }))
  default = {}
}

variable "skip_credentials_validation" {
  description = "CI override only: skip provider credential validation."
  type        = bool
  default     = false

  validation {
    condition     = var.allow_provider_skip_checks || !var.skip_credentials_validation
    error_message = "skip_credentials_validation requires allow_provider_skip_checks = true."
  }
}

variable "skip_requesting_account_id" {
  description = "CI override only: skip account ID request."
  type        = bool
  default     = false

  validation {
    condition     = var.allow_provider_skip_checks || !var.skip_requesting_account_id
    error_message = "skip_requesting_account_id requires allow_provider_skip_checks = true."
  }
}

variable "skip_metadata_api_check" {
  description = "CI override only: skip metadata API check."
  type        = bool
  default     = false

  validation {
    condition     = var.allow_provider_skip_checks || !var.skip_metadata_api_check
    error_message = "skip_metadata_api_check requires allow_provider_skip_checks = true."
  }
}

variable "allow_provider_skip_checks" {
  description = "Set true only for CI pipelines that need provider skip checks."
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
