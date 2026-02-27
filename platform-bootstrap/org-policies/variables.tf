variable "environment" {
  type        = string
  description = "Execution environment scope, typically 'root' or 'shared' for org policies."
}

variable "org_policy_deny_leaving_org_enabled" {
  type        = bool
  description = "Enable the deny-leaving-org policy"
  default     = true
}

variable "org_policy_protect_security_services_enabled" {
  type        = bool
  description = "Enable the protect-security-services policy"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
