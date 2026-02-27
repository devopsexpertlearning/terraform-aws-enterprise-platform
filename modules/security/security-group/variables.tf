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
  description = "Name for the security group."
  type        = string
}

variable "description" {
  description = "Description of the security group."
  type        = string
  default     = "Security group managed by Terraform"
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules."
  type = list(object({
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    self                     = optional(bool, false)
    source_security_group_id = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      (length(try(rule.cidr_blocks, [])) > 0 ? 1 : 0) +
      (try(rule.self, false) ? 1 : 0) +
      (try(rule.source_security_group_id, null) != null ? 1 : 0) == 1
    ])
    error_message = "Each ingress rule must define exactly one source: cidr_blocks, self=true, or source_security_group_id."
  }
}

variable "egress_rules" {
  description = "List of egress rules."
  type = list(object({
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    self                     = optional(bool, false)
    source_security_group_id = optional(string)
  }))
  default = [
    {
      description              = "Allow all outbound"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      self                     = false
      source_security_group_id = null
    }
  ]

  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      (length(try(rule.cidr_blocks, [])) > 0 ? 1 : 0) +
      (try(rule.self, false) ? 1 : 0) +
      (try(rule.source_security_group_id, null) != null ? 1 : 0) == 1
    ])
    error_message = "Each egress rule must define exactly one destination: cidr_blocks, self=true, or source_security_group_id."
  }
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
