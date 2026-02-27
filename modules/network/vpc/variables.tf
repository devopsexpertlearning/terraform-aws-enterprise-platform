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

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Must be a valid CIDR block."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && can(cidrnetmask(var.vpc_cidr))
    error_message = "VPC CIDR must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets. Must match the number of availability zones."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) > 0 && length(var.public_subnet_cidrs) <= 3
    error_message = "Public subnet CIDRs must have between 1 and 3 entries."
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets. Must match the number of availability zones."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) > 0 && length(var.private_subnet_cidrs) <= 3
    error_message = "Private subnet CIDRs must have between 1 and 3 entries."
  }
}

variable "isolated_subnet_cidrs" {
  description = "List of CIDR blocks for isolated subnets (e.g., for RDS). Must match the number of availability zones."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.isolated_subnet_cidrs) <= 3
    error_message = "Isolated subnet CIDRs must have at most 3 entries."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use. If empty, will use all available AZs in the region."
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets. If false, one NAT gateway per AZ is created."
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs."
  type        = bool
  default     = true
}

variable "vpc_flow_logs_destination_type" {
  description = "The type of destination for VPC Flow Logs (cloud-watch-logs or s3)."
  type        = string
  default     = "cloud-watch-logs"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.vpc_flow_logs_destination_type)
    error_message = "VPC Flow Logs destination type must be 'cloud-watch-logs' or 's3'."
  }
}

variable "vpc_flow_logs_log_group_name" {
  description = "CloudWatch Log Group name for VPC Flow Logs."
  type        = string
  default     = ""
}

variable "vpc_flow_logs_s3_bucket_arn" {
  description = "S3 bucket ARN for VPC Flow Logs. Required if destination_type is s3."
  type        = string
  default     = ""
}

variable "transit_gateway_id" {
  description = "ID of an existing Transit Gateway to attach to. If empty, no attachment is created."
  type        = string
  default     = ""
}

variable "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table to use for the attachment."
  type        = string
  default     = ""
}

variable "enable_internet_gateway" {
  description = "Create an Internet Gateway. If false, no IGW is created."
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Optional prefix for resource names. If empty, project_name will be used."
  type        = string
  default     = ""
}

locals {
  standard_name_prefix = "${var.project_name}-${var.environment}"

  name_prefix = var.name_prefix != "" ? var.name_prefix : var.project_name

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

  az_count = length(var.availability_zones) > 0 ? length(var.availability_zones) : (
    var.single_nat_gateway ? 1 : length(data.aws_availability_zones.available.names)
  )
}
