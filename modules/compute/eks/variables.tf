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
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g., 1.28)."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the cluster will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cluster and node groups. Must be private subnets."
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the EKS node groups."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting Kubernetes secrets (envelope encryption)."
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "Additional security group IDs for the cluster."
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Enable private endpoint access."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public endpoint access. Recommended to be false in production."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks that can access the public API endpoint."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.public_access_cidrs : cidr != "0.0.0.0/0"])
    error_message = "Do not use 0.0.0.0/0 for EKS public endpoint access."
  }

  validation {
    condition     = var.endpoint_public_access ? length(var.public_access_cidrs) > 0 : length(var.public_access_cidrs) == 0
    error_message = "Set public_access_cidrs only when endpoint_public_access is true."
  }
}

variable "cluster_enabled_log_types" {
  description = "List of log types to enable for the cluster."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_eks_cluster_log_to_cloudwatch" {
  description = "Send EKS cluster logs to CloudWatch."
  type        = bool
  default     = true
}

variable "cluster_log_retention_days" {
  description = "CloudWatch log retention days."
  type        = number
  default     = 90
}

variable "node_groups" {
  description = "Map of node groups to provision."
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    ami_type            = string
    ami_release_version = string
  }))
  default = {}
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)."
  type        = bool
  default     = true
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
