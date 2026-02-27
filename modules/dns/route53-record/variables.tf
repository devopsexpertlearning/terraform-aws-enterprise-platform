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

variable "zone_id" {
  description = "The ID of the hosted zone."
  type        = string
}

variable "name" {
  description = "The name of the record."
  type        = string
}

variable "type" {
  description = "The record type (A, AAAA, CNAME, TXT, MX, etc.)."
  type        = string
}

variable "ttl" {
  description = "The TTL of the record."
  type        = number
  default     = 300
}

variable "records" {
  description = "List of record values."
  type        = list(string)
  default     = []
}

variable "alias" {
  description = "Alias target configuration."
  type = object({
    name                   = string
    zone_id                = string
    evaluate_target_health = bool
  })
  default = null
}

variable "set_identifier" {
  description = "Set identifier for routing policy."
  type        = string
  default     = ""
}

variable "health_check_id" {
  description = "Health check ID."
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
