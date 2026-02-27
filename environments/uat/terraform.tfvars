aws_region   = "us-east-1"
project_name = "enterprise-platform"
environment  = "uat"
owner        = "platform-team"
cost_center  = "CC-1000"

vpc_cidr              = "10.20.0.0/16"
public_subnet_cidrs   = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs  = ["10.20.11.0/24", "10.20.12.0/24"]
isolated_subnet_cidrs = ["10.20.21.0/24", "10.20.22.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]
single_nat_gateway    = true

workload_name    = "app"
ami_id           = "ami-REPLACE-UAT"
instance_type    = "t3.large"
root_volume_size = 80

enable_customer_managed_kms = true
kms_key_user_arns           = ["arn:aws:iam::123456789012:role/platform-admin"]

termination_protection = true
monitoring_enabled     = true

ssh_ingress_cidrs = ["203.0.113.10/32"]

additional_tags = {
  DataClassification = "internal"
}
