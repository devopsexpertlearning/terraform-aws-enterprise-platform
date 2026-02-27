module "network" {
  source = "../../modules/network/vpc"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs
  availability_zones    = var.availability_zones

  single_nat_gateway = var.single_nat_gateway

  additional_tags = var.additional_tags
}

module "ec2_kms" {
  count  = var.enable_customer_managed_kms ? 1 : 0
  source = "../../modules/security/kms"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  description   = "CMK for ${var.project_name}-${var.environment}-${var.workload_name} EC2"
  alias_name    = "alias/${var.project_name}-${var.environment}-${var.workload_name}-ec2"
  key_user_arns = var.kms_key_user_arns

  additional_tags = var.additional_tags
}

module "app_security_group" {
  source = "../../modules/security/security-group"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name        = "${var.workload_name}-sg-01"
  description = "Security group for ${var.workload_name}"
  vpc_id      = module.network.vpc_id

  ingress_rules = local.app_ingress_rules

  egress_rules = [
    {
      description = "HTTPS outbound"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = false
    }
  ]

  additional_tags = var.additional_tags
}

module "app_server" {
  source = "../../modules/compute/ec2"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name                   = "${var.workload_name}-01"
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.network.private_subnet_ids[0]
  vpc_security_group_ids = [module.app_security_group.security_group_id]

  kms_key_arn = var.enable_customer_managed_kms ? module.ec2_kms[0].key_arn : ""

  root_volume_size       = var.root_volume_size
  monitoring_enabled     = var.monitoring_enabled
  termination_protection = var.termination_protection

  associate_public_ip_address = false
  additional_ebs_volumes      = var.additional_ebs_volumes

  additional_tags = var.additional_tags
}
