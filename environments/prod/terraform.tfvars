aws_region   = "us-east-1"
project_name = "enterprise-platform"
environment  = "prod"
owner        = "platform-team"
cost_center  = "CC-1000"

vpc_cidr              = "10.30.0.0/16"
public_subnet_cidrs   = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
private_subnet_cidrs  = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
isolated_subnet_cidrs = ["10.30.21.0/24", "10.30.22.0/24", "10.30.23.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
single_nat_gateway    = false

workload_name    = "app"
ami_id           = "ami-REPLACE-PROD"
instance_type    = "m6i.large"
root_volume_size = 120

enable_customer_managed_kms = true
kms_key_user_arns           = ["arn:aws:iam::123456789012:role/platform-admin"]

termination_protection = true
monitoring_enabled     = true

ssh_ingress_cidrs = ["198.51.100.25/32"]

additional_tags = {
  DataClassification = "confidential"
  Compliance         = "required"
}
