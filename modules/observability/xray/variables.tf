variable "project_name" {
  type        = string
  description = "Project name for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier."
}

variable "enable_xray" {
  type        = bool
  description = "Whether to enable X-Ray tracing resources."
  default     = true
}

variable "sampling_rate" {
  type        = number
  description = "The percentage of requests to sample (0.0 to 1.0)."
  default     = 0.05
}
