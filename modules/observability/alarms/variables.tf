variable "project_name" {
  type        = string
  description = "Project name for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier."
}

variable "alarm_name" {
  type        = string
  description = "Descriptive name for the alarm."
}

variable "comparison_operator" {
  type        = string
  description = "Comparison operator: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold."
  default     = "GreaterThanOrEqualToThreshold"
}

variable "evaluation_periods" {
  type        = number
  description = "Number of evaluation periods before triggering."
  default     = 2
}

variable "metric_name" {
  type        = string
  description = "The CloudWatch metric name."
}

variable "namespace" {
  type        = string
  description = "The CloudWatch namespace for the metric."
}

variable "period" {
  type        = number
  description = "The period in seconds over which the statistic is applied."
  default     = 300
}

variable "statistic" {
  type        = string
  description = "The statistic to apply: Average, Sum, Minimum, Maximum, SampleCount."
  default     = "Average"
}

variable "threshold" {
  type        = number
  description = "The threshold value to trigger the alarm."
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "List of SNS topic ARNs to notify when the alarm fires."
  default     = []
}

variable "dimensions" {
  type        = map(string)
  description = "Map of dimensions for the metric."
  default     = {}
}
