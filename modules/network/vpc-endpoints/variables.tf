variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "The environment context."
  type        = string
}

variable "owner" {
  description = "The owner/team responsible."
  type        = string
  default     = ""
}

variable "cost_center" {
  description = "The cost center."
  type        = string
  default     = "UNKNOWN"
}

variable "vpc_id" {
  description = "VPC ID where endpoints will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for the Endpoint Security Group Ingress"
  type        = string
}

variable "private_route_table_ids" {
  description = "Route tables to attach Gateway Endpoints (S3/Dynamo) to"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnets to deploy Interface Endpoints into"
  type        = list(string)
}

variable "enable_interface_endpoints" {
  description = "Whether to deploy the expensive interface endpoints. Should be false for pure sandbox accounts, true for Prod/QA."
  type        = bool
  default     = true
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
  }
}
