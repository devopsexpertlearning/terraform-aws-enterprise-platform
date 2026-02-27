variable "project_name" {
  type        = string
  description = "Project name for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier."
}

variable "topic_name" {
  type        = string
  description = "The name of the SNS Topic."
}

variable "kms_key_arn" {
  type        = string
  description = "Enterprise CMK ARN to encrypt SNS messages at rest."
}

variable "subscription_endpoints" {
  type = list(object({
    protocol = string
    endpoint = string
  }))
  description = "List of subscriptions. Protocol can be email, sqs, lambda, https, etc."
  default     = []
}
