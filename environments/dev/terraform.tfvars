aws_region   = "us-east-1"
project_name = "platform"
environment  = "dev"
owner        = "platform-team"
cost_center  = "CC-1000"

vpc_cidr              = "10.10.0.0/16"
public_subnet_cidrs   = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs  = ["10.10.11.0/24", "10.10.12.0/24"]
isolated_subnet_cidrs = ["10.10.21.0/24", "10.10.22.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
single_nat_gateway    = true

kms_key_user_arns = []

workload_name    = "app"
ami_id           = ""
instance_type    = "t3.medium"
root_volume_size = 50

termination_protection = false
monitoring_enabled     = true
ssh_ingress_cidrs      = ["203.0.113.10/32"]

additional_ebs_volumes = {
  data1 = {
    device_name = "/dev/sdf"
    size        = 20
    type        = "gp3"
    kms_key_arn = ""
  }
}

logging_bucket_name    = "enterprise-platform-dev-logs-123456"
artifact_bucket_suffix = "artifacts"
cloudtrail_name        = "platform-trail"

alert_email_addresses = []

acm_certificate_arn = ""

route53_zone_name   = "dev.internal"
route53_record_name = "app"

ebs_volume_size = 20

ecs_container_name  = "app"
ecs_container_image = "public.ecr.aws/docker/library/nginx:stable"

lambda_image_uri = ""

db_secret_string      = "ChangeMe-ReplaceInSecretsManager-123!"
db_master_username    = "platformadmin"
rds_engine_version    = ""
rds_instance_class    = "db.t3.medium"
rds_allocated_storage = 100

aurora_engine_version = ""
aurora_instance_class = "db.t3.medium"

elasticache_node_type = "cache.t3.small"

kubernetes_version = "1.30"
eks_node_groups = {
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

additional_tags = {
  DataClassification = "internal"
  SmokeTest          = "all-modules"
}
