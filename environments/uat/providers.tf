provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }

  skip_credentials_validation = var.skip_credentials_validation
  skip_requesting_account_id  = var.skip_requesting_account_id
  skip_metadata_api_check     = var.skip_metadata_api_check
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

  app_ingress_rules = concat(
    [
      {
        description = "HTTPS from inside VPC"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
        self        = false
      }
    ],
    [for cidr in var.ssh_ingress_cidrs : {
      description = "SSH admin access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [cidr]
      self        = false
    }]
  )
}
