variable "project_name" {
  type        = string
  description = "The overarching project name."
}

variable "environment" {
  type        = string
  description = "Environment name, e.g., 'primary', 'management', or 'shared'."
}

variable "is_org_trail" {
  type        = bool
  description = "Set to true if applying from the Management account to enable org-wide trails."
  default     = false
}
