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
  workload_base_name       = var.workload_name
  alb_name                 = "${local.workload_base_name}-alb"
  alb_target_group_name_02 = "${local.alb_name}-tg-02"
  effective_ami_id         = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.al2023_ami.value
  effective_rds_engine_version = (
    var.rds_engine_version != "" ?
    var.rds_engine_version :
    data.aws_rds_engine_version.postgres_default.version
  )
  effective_aurora_engine_version = (
    var.aurora_engine_version != "" ?
    var.aurora_engine_version :
    data.aws_rds_engine_version.aurora_postgres_default.version
  )

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
