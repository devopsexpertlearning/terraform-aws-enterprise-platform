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

variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "description" {
  description = "Description of the Lambda function."
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Runtime for the Lambda function (e.g., python3.9, nodejs18.x)."
  type        = string
  default     = null
  nullable    = true
}

variable "handler" {
  description = "Function entry point."
  type        = string
  default     = null
  nullable    = true
}

variable "lambda_role_arn" {
  description = "IAM role ARN for the Lambda function."
  type        = string
}

variable "package_type" {
  description = "Lambda package type: Zip or Image."
  type        = string
  default     = "Zip"

  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "package_type must be either Zip or Image."
  }

  validation {
    condition = var.package_type == "Image" ? (
      var.image_uri != "" &&
      var.filename == "" &&
      var.s3_bucket == "" &&
      var.s3_key == "" &&
      var.runtime == null &&
      var.handler == null
      ) : (
      (var.filename != "" || (var.s3_bucket != "" && var.s3_key != "")) &&
      var.image_uri == "" &&
      var.runtime != null &&
      var.handler != null
    )
    error_message = "For Zip packages, set runtime/handler and one source (filename or s3_bucket+s3_key). For Image packages, set image_uri only and leave runtime/handler empty."
  }
}

variable "filename" {
  description = "Path to deployment package zip file."
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package zip file."
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 key of the deployment package zip file."
  type        = string
  default     = ""
}

variable "s3_object_version" {
  description = "Optional S3 object version for deployment package."
  type        = string
  default     = ""
}

variable "image_uri" {
  description = "Container image URI when package_type is Image."
  type        = string
  default     = ""
}

variable "source_code_hash" {
  description = "Source code hash for triggering updates."
  type        = string
  default     = ""

  validation {
    condition     = var.package_type == "Image" ? var.source_code_hash == "" : true
    error_message = "source_code_hash must be empty when package_type is Image."
  }
}

variable "memory_size" {
  description = "Memory size in MB."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Function timeout in seconds."
  type        = number
  default     = 30
}

variable "publish" {
  description = "Publish the function version."
  type        = bool
  default     = true
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function."
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "environment_variables" {
  description = "Environment variables for the function."
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for environment variable encryption."
  type        = string
  default     = ""
}

variable "tracing_config" {
  description = "X-Ray tracing configuration."
  type = object({
    mode = string
  })
  default = null
}

variable "vpc_id" {
  description = "The VPC ID (required if vpc_config is provided)."
  type        = string
  default     = ""
}

variable "dead_letter_config" {
  description = "Dead letter queue configuration."
  type = object({
    target_arn = string
  })
  default = null
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions."
  type        = number
  default     = -1
}

variable "layers" {
  description = "List of Lambda layer ARNs."
  type        = list(string)
  default     = []
}

variable "architectures" {
  description = "Instruction set architecture for the function."
  type        = list(string)
  default     = ["x86_64"]
}

variable "cloudwatch_log_group_retention_days" {
  description = "CloudWatch log group retention days."
  type        = number
  default     = 90
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "efs_mount_target" {
  description = "EFS mount target configuration."
  type = object({
    local_mount_path = string
    arn              = string
  })
  default = null
}

variable "async_config" {
  description = "Asynchronous invocation configuration."
  type = object({
    destination_on_failure       = optional(string)
    destination_on_success       = optional(string)
    maximum_event_age_in_seconds = optional(number, 3600)
    maximum_retry_attempts       = optional(number, 2)
  })
  default = null
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
