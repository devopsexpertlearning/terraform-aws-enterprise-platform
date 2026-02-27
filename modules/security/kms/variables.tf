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

variable "description" {
  description = "Description of the KMS key."
  type        = string
  default     = "KMS key managed by Terraform"
}

variable "key_usage" {
  description = "Key usage (ENCRYPT_DECRYPT or SIGN_VERIFY)."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "key_spec" {
  description = "Key spec (SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, etc.)."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "deletion_window_in_days" {
  description = "Deletion window in days."
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable key rotation."
  type        = bool
  default     = true
}

variable "alias_name" {
  description = "Alias name for the KMS key."
  type        = string
  default     = ""
}

variable "policy" {
  description = "KMS key policy (JSON)."
  type        = string
  default     = ""
}

variable "key_user_arns" {
  description = "IAM principal ARNs allowed to use this KMS key for cryptographic operations."
  type        = list(string)
  default     = []
}

variable "grants" {
  description = "List of grants to create."
  type = list(object({
    name              = string
    grantee_principal = string
    operations        = list(string)
    key_id            = string
  }))
  default = []
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
