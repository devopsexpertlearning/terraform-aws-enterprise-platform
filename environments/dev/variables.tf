variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "environment must be one of: dev, uat, prod."
  }
}

variable "owner" {
  description = "Owning team or person."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag value."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets."
  type        = list(string)
}

variable "isolated_subnet_cidrs" {
  description = "CIDRs for isolated subnets."
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "Availability zones to use."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "If true, creates one NAT gateway for all private subnets."
  type        = bool
  default     = true
}

variable "kms_key_user_arns" {
  description = "Principal ARNs allowed to use the customer-managed KMS key."
  type        = list(string)
  default     = []
}

variable "workload_name" {
  description = "Logical workload name used in resource names."
  type        = string
  default     = "app"
}

variable "ami_id" {
  description = "AMI ID for EC2 and launch template instances. Leave empty to auto-resolve latest Amazon Linux 2023 AMI via SSM."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 50
}

variable "termination_protection" {
  description = "Enable EC2 termination protection."
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = true
}

variable "ssh_ingress_cidrs" {
  description = "Administrative CIDRs allowed SSH access. Keep empty unless needed."
  type        = list(string)
  default     = []
}

variable "additional_ebs_volumes" {
  description = "Additional EBS volumes to attach to instance."
  type = map(object({
    device_name = string
    size        = number
    type        = string
    kms_key_arn = string
  }))
  default = {}
}

variable "logging_bucket_name" {
  description = "Name for the centralized logging bucket used by logging module."
  type        = string
}

variable "artifact_bucket_suffix" {
  description = "Suffix used by storage/s3 module for artifact bucket creation."
  type        = string
}

variable "cloudtrail_name" {
  description = "CloudTrail trail name suffix."
  type        = string
  default     = "platform-trail"
}

variable "alert_email_addresses" {
  description = "Email endpoints for SNS alert subscriptions."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for ALB HTTPS listener. Leave empty to skip HTTPS listener."
  type        = string
  default     = ""
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name used for DNS module test."
  type        = string
}

variable "route53_record_name" {
  description = "Record name to create in Route53 zone."
  type        = string
  default     = "app"
}

variable "ebs_volume_size" {
  description = "Standalone EBS module volume size in GiB."
  type        = number
  default     = 50
}

variable "ecs_container_name" {
  description = "Container name for ECS task definition smoke test."
  type        = string
  default     = "app"
}

variable "ecs_container_image" {
  description = "Container image for ECS task definition smoke test."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable"
}

variable "lambda_image_uri" {
  description = "Container image URI for Lambda image package smoke test."
  type        = string
  default     = "public.ecr.aws/lambda/python:3.12"
}

variable "db_secret_string" {
  description = "Master DB password stored in Secrets Manager."
  type        = string
  sensitive   = true
}

variable "db_master_username" {
  description = "Master DB username for RDS and Aurora modules."
  type        = string
  default     = "platformadmin"
}

variable "rds_engine_version" {
  description = "Engine version for RDS PostgreSQL module. Leave empty to auto-resolve default region version."
  type        = string
  default     = ""
}

variable "rds_instance_class" {
  description = "Instance class for RDS module."
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS in GiB."
  type        = number
  default     = 100
}

variable "aurora_engine_version" {
  description = "Aurora PostgreSQL engine version. Leave empty to auto-resolve default region version."
  type        = string
  default     = ""
}

variable "aurora_instance_class" {
  description = "Instance class for Aurora instances."
  type        = string
  default     = "db.t3.medium"
}

variable "elasticache_node_type" {
  description = "Node type for ElastiCache module."
  type        = string
  default     = "cache.t3.small"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "eks_node_groups" {
  description = "Node groups definition for EKS module."
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    ami_type            = string
    ami_release_version = string
  }))
  default = {
    default = {
      instance_types      = ["t3.medium"]
      min_size            = 1
      max_size            = 2
      desired_size        = 1
      capacity_type       = "ON_DEMAND"
      disk_size           = 30
      labels              = { role = "general" }
      taints              = []
      ami_type            = "AL2_x86_64"
      ami_release_version = ""
    }
  }
}

variable "skip_credentials_validation" {
  description = "CI override only: skip provider credential validation."
  type        = bool
  default     = false

  validation {
    condition     = var.allow_provider_skip_checks || !var.skip_credentials_validation
    error_message = "skip_credentials_validation requires allow_provider_skip_checks = true."
  }
}

variable "skip_requesting_account_id" {
  description = "CI override only: skip account ID request."
  type        = bool
  default     = false

  validation {
    condition     = var.allow_provider_skip_checks || !var.skip_requesting_account_id
    error_message = "skip_requesting_account_id requires allow_provider_skip_checks = true."
  }
}

variable "skip_metadata_api_check" {
  description = "CI override only: skip metadata API check."
  type        = bool
  default     = false

  validation {
    condition     = var.allow_provider_skip_checks || !var.skip_metadata_api_check
    error_message = "skip_metadata_api_check requires allow_provider_skip_checks = true."
  }
}

variable "allow_provider_skip_checks" {
  description = "Set true only for CI pipelines that need provider skip checks."
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
