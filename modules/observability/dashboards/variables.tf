variable "project_name" {
  type        = string
  description = "Project name for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier."
}

variable "dashboard_name" {
  type        = string
  description = "Name for the CloudWatch Dashboard."
}

variable "dashboard_body" {
  type        = string
  description = "JSON body defining the dashboard widgets. Use jsonencode() from the caller."
}
