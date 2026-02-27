variable "name" {
  type        = string
  description = "Name of the security group"
}

variable "description" {
  type        = string
  description = "Description of the security group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the SG will be created"
}

variable "ingress_rules" {
  description = "List of ingress rules. Each rule is a map with keys: from_port, to_port, protocol, cidr_blocks (list), security_groups (list), self (bool), description"
  type        = any
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules. Empty by default to enforce explicit egress rules, overriding the AWS 'allow all' default."
  type        = any
  default     = []
}

variable "project_name" {}
variable "environment" {}
