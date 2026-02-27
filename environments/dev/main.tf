data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_rds_engine_version" "postgres_default" {
  engine       = "postgres"
  default_only = true
}

data "aws_rds_engine_version" "aurora_postgres_default" {
  engine       = "aurora-postgresql"
  default_only = true
}

data "archive_file" "lambda_smoke_test" {
  type        = "zip"
  output_path = "${path.root}/.terraform/lambda-smoke-test.zip"

  source {
    filename = "lambda_function.py"
    content  = <<-PY
def handler(event, context):
    return {"statusCode": 200, "body": "ok"}
PY
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "boundary_test_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

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
  source = "../../modules/security/kms"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  description   = "KMS key for ${var.project_name}-${var.environment} dev validation"
  alias_name    = "alias/${var.project_name}-${var.environment}-validation"
  key_user_arns = var.kms_key_user_arns

  additional_tags = var.additional_tags
}

module "s3_logging" {
  source = "../../modules/logging/s3-logging"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  bucket_name = var.logging_bucket_name
  lifecycle_rules = [
    {
      id              = "expire-old-logs"
      enabled         = true
      expiration_days = 365
    }
  ]
}

module "artifact_bucket" {
  source = "../../modules/storage/s3"

  project_name = var.project_name
  environment  = var.environment

  bucket_name_suffix = var.artifact_bucket_suffix
  kms_key_arn        = module.ec2_kms.key_arn
}

module "cloudtrail" {
  source = "../../modules/logging/cloudtrail"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name           = var.cloudtrail_name
  s3_bucket_name = module.s3_logging.bucket_name
  kms_key_arn    = module.ec2_kms.key_arn
}

module "vpc_flow_logs_extra" {
  source = "../../modules/network/flow-logs"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  vpc_id               = module.network.vpc_id
  log_destination_type = "s3"
  log_destination_arn  = module.artifact_bucket.bucket_arn
}

module "vpc_endpoints" {
  source = "../../modules/network/vpc-endpoints"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  vpc_id                  = module.network.vpc_id
  vpc_cidr                = var.vpc_cidr
  private_route_table_ids = module.network.private_route_table_ids
  subnet_ids              = module.network.private_subnet_ids
}

module "iam_boundary_policy" {
  source = "../../modules/security/iam-policy"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name        = "boundary-policy"
  description = "Boundary policy for validation role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:Describe*", "logs:Describe*", "s3:ListAllMyBuckets"]
        Resource = "*"
      }
    ]
  })
}

module "iam_app_policy" {
  source = "../../modules/security/iam-policy"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name        = "app-policy"
  description = "Application policy for module integration"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "secretsmanager:GetSecretValue",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

module "iam_role_ec2" {
  source = "../../modules/security/iam-role"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = "ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    module.iam_app_policy.policy_arn
  ]
}

module "iam_role_lambda" {
  source = "../../modules/security/iam-role"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    module.iam_app_policy.policy_arn
  ]
}

module "iam_role_ecs_execution" {
  source = "../../modules/security/iam-role"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = "ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

module "iam_role_ecs_task" {
  source = "../../modules/security/iam-role"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  policy_arns = [
    module.iam_app_policy.policy_arn
  ]
}

module "iam_role_eks_cluster" {
  source = "../../modules/security/iam-role"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

module "iam_role_eks_node" {
  source = "../../modules/security/iam-role"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = "eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

module "iam_role_boundary_test" {
  source = "../../modules/security/iam-role-boundary"

  project_name = var.project_name
  environment  = var.environment

  role_name                = "boundary-test-role"
  assume_role_policy       = data.aws_iam_policy_document.boundary_test_assume_role.json
  permissions_boundary_arn = module.iam_boundary_policy.policy_arn
  managed_policy_arns = [
    module.iam_app_policy.policy_arn
  ]
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = module.iam_role_ec2.role_name
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
    }
  ]

  additional_tags = var.additional_tags
}

module "db_security_group" {
  source = "../../modules/security/security-group"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name        = "db-sg-02"
  description = "Database tier security group"
  vpc_id      = module.network.vpc_id

  ingress_rules = [
    {
      description              = "PostgreSQL from app"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.app_security_group.security_group_id
      self                     = false
    },
    {
      description              = "Redis from app"
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      source_security_group_id = module.app_security_group.security_group_id
      self                     = false
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  additional_tags = var.additional_tags
}

module "security_group_baseline" {
  source = "../../modules/security/security-group-baseline"

  project_name = var.project_name
  environment  = var.environment

  name        = "baseline-sg-03"
  description = "Baseline deny-by-default SG"
  vpc_id      = module.network.vpc_id

  ingress_rules = []
  egress_rules  = []
}

module "cloudwatch_app" {
  source = "../../modules/observability/cloudwatch"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  log_group_name    = "application"
  retention_in_days = 90
  kms_key_arn       = module.ec2_kms.key_arn

  additional_tags = var.additional_tags
}

module "sns_alerts" {
  source = "../../modules/observability/sns"

  project_name = var.project_name
  environment  = var.environment

  topic_name  = "platform-alerts"
  kms_key_arn = module.ec2_kms.key_arn

  subscription_endpoints = [
    for email in var.alert_email_addresses : {
      protocol = "email"
      endpoint = email
    }
  ]
}

module "alarm_high_cpu" {
  source = "../../modules/observability/alarms"

  project_name = var.project_name
  environment  = var.environment

  alarm_name  = "ec2-high-cpu"
  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"
  threshold   = 80
  dimensions = {
    InstanceId = module.app_server.instance_id
  }
  sns_topic_arns = [module.sns_alerts.topic_arn]
}

module "dashboard" {
  source = "../../modules/observability/dashboards"

  project_name = var.project_name
  environment  = var.environment

  dashboard_name = "platform-overview"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", module.app_server.instance_id]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 CPU"
        }
      }
    ]
  })
}

module "xray" {
  source = "../../modules/observability/xray"

  project_name = var.project_name
  environment  = var.environment
}

module "target_group" {
  source = "../../modules/load-balancing/target-group"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name        = local.alb_target_group_name_02
  vpc_id      = module.network.vpc_id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
}

module "alb" {
  source = "../../modules/load-balancing/alb"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = local.alb_name
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [module.app_security_group.security_group_id]

  internal                    = false
  enable_deletion_protection  = false
  access_logs_bucket          = module.s3_logging.bucket_name
  default_ssl_certificate_arn = var.acm_certificate_arn

  additional_tags = var.additional_tags
}

module "nlb" {
  source = "../../modules/load-balancing/nlb"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name       = "app-nlb"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnet_ids

  internal                   = false
  enable_deletion_protection = false

  target_group_arn = ""
}

module "waf" {
  source = "../../modules/security/waf"

  project_name = var.project_name
  environment  = var.environment

  waf_name                = "app-waf"
  scope                   = "REGIONAL"
  associated_resource_arn = null
}

module "route53_zone" {
  source = "../../modules/dns/route53-zone"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  zone_name     = var.route53_zone_name
  vpc_id        = module.network.vpc_id
  force_destroy = true

  additional_tags = var.additional_tags
}

module "route53_record" {
  source = "../../modules/dns/route53-record"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  zone_id = module.route53_zone.zone_id
  name    = var.route53_record_name
  type    = "CNAME"
  ttl     = 60
  records = [module.alb.alb_dns_name]

  additional_tags = var.additional_tags
}

module "efs" {
  source = "../../modules/storage/efs"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name               = "shared-efs"
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [module.app_security_group.security_group_id]
  kms_key_arn        = module.ec2_kms.key_arn

  additional_tags = var.additional_tags
}

module "ebs" {
  source = "../../modules/storage/ebs"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name              = "standalone-ebs"
  availability_zone = var.availability_zones[0]
  size              = var.ebs_volume_size
  kms_key_arn       = module.ec2_kms.key_arn

  additional_tags = var.additional_tags
}

module "launch_template" {
  source = "../../modules/compute/launch-template"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name                   = "app-lt"
  image_id               = local.effective_ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2.arn
  vpc_security_group_ids = [module.app_security_group.security_group_id]
  kms_key_arn            = module.ec2_kms.key_arn

  user_data = <<-EOT
#!/bin/bash
echo "launch-template-smoke-test" > /tmp/bootstrap.txt
EOT

  additional_tags = var.additional_tags
}

module "asg" {
  source = "../../modules/compute/asg"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name                = "app-asg"
  launch_template_id  = module.launch_template.launch_template_id
  vpc_zone_identifier = module.network.private_subnet_ids
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  health_check_type   = "EC2"
  target_group_arns   = []

  additional_tags = var.additional_tags
}

module "app_server" {
  source = "../../modules/compute/ec2"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  name                   = "${var.workload_name}-01"
  ami_id                 = local.effective_ami_id
  instance_type          = var.instance_type
  subnet_id              = module.network.private_subnet_ids[0]
  vpc_security_group_ids = [module.app_security_group.security_group_id]

  iam_instance_profile_name = aws_iam_instance_profile.ec2.name
  kms_key_arn               = module.ec2_kms.key_arn

  root_volume_size       = var.root_volume_size
  monitoring_enabled     = var.monitoring_enabled
  termination_protection = var.termination_protection

  associate_public_ip_address = false
  additional_ebs_volumes      = var.additional_ebs_volumes

  additional_tags = var.additional_tags
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = module.iam_role_ecs_execution.role_arn
  task_role_arn            = module.iam_role_ecs_task.role_arn

  container_definitions = jsonencode([
    {
      name      = var.ecs_container_name
      image     = var.ecs_container_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = module.cloudwatch_app.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

module "ecs" {
  source = "../../modules/compute/ecs"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  cluster_name = "app-ecs"
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids

  cloudwatch_log_group_name = ""
  kms_key_arn               = module.ec2_kms.key_arn

  service_definition = {
    task_definition = aws_ecs_task_definition.app.arn
    desired_count   = 1
    launch_type     = "FARGATE"
    network_configuration = {
      subnets          = module.network.private_subnet_ids
      security_groups  = [module.app_security_group.security_group_id]
      assign_public_ip = false
    }
    load_balancer = {
      target_group_arn = module.alb.target_group_arn
      container_name   = var.ecs_container_name
      container_port   = 80
    }
  }

  additional_tags = var.additional_tags
}

module "lambda" {
  source = "../../modules/compute/lambda"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  function_name    = "validation-function"
  lambda_role_arn  = module.iam_role_lambda.role_arn
  package_type     = "Zip"
  runtime          = "python3.12"
  handler          = "lambda_function.handler"
  filename         = data.archive_file.lambda_smoke_test.output_path
  source_code_hash = data.archive_file.lambda_smoke_test.output_base64sha256
  timeout          = 30
  memory_size      = 256
  kms_key_arn      = module.ec2_kms.key_arn
  tracing_config   = { mode = "Active" }

  vpc_config = {
    subnet_ids         = module.network.private_subnet_ids
    security_group_ids = [module.app_security_group.security_group_id]
  }

  environment_variables = {
    ENVIRONMENT = var.environment
    PROJECT     = var.project_name
  }

  additional_tags = var.additional_tags
}

module "db_secret" {
  source = "../../modules/security/secrets-manager"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  secret_name   = "database/master-password"
  kms_key_arn   = module.ec2_kms.key_arn
  secret_string = var.db_secret_string

  additional_tags = var.additional_tags
}

module "rds" {
  source = "../../modules/database/rds"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  identifier          = "app-rds"
  engine              = "postgres"
  engine_version      = local.effective_rds_engine_version
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  db_name             = "appdb"
  username            = var.db_master_username
  password_secret_arn = module.db_secret.secret_arn
  kms_key_arn         = module.ec2_kms.key_arn
  subnet_ids          = module.network.isolated_subnet_ids
  vpc_security_group_ids = [
    module.db_security_group.security_group_id
  ]

  publicly_accessible = false
  deletion_protection = false
  skip_final_snapshot = true

  additional_tags = var.additional_tags
}

module "aurora" {
  source = "../../modules/database/aurora"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  cluster_identifier  = "app-aurora"
  engine              = "aurora-postgresql"
  engine_version      = local.effective_aurora_engine_version
  database_name       = "appaurora"
  master_username     = var.db_master_username
  password_secret_arn = module.db_secret.secret_arn
  instance_class      = var.aurora_instance_class
  subnet_ids          = module.network.isolated_subnet_ids
  vpc_security_group_ids = [
    module.db_security_group.security_group_id
  ]
  kms_key_arn = module.ec2_kms.key_arn

  instances = {
    writer = 1
    reader = 1
  }

  deletion_protection = false
  skip_final_snapshot = true

  additional_tags = var.additional_tags
}

module "dynamodb" {
  source = "../../modules/database/dynamodb"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  table_name = "app-table"
  hash_key   = "id"
  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
  kms_key_arn = module.ec2_kms.key_arn

  additional_tags = var.additional_tags
}

module "elasticache" {
  source = "../../modules/database/elasticache"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  cluster_name = "app-cache"
  engine       = "redis"
  node_type    = var.elasticache_node_type

  subnet_ids = module.network.isolated_subnet_ids
  security_group_ids = [
    module.db_security_group.security_group_id
  ]

  multi_az_enabled           = true
  automatic_failover_enabled = true
  kms_key_id                 = module.ec2_kms.key_arn

  additional_tags = var.additional_tags
}

module "eks" {
  source = "../../modules/compute/eks"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center

  cluster_name       = "app-eks"
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.private_subnet_ids
  cluster_role_arn   = module.iam_role_eks_cluster.role_arn
  node_role_arn      = module.iam_role_eks_node.role_arn
  kms_key_arn        = module.ec2_kms.key_arn
  vpc_security_group_ids = [
    module.app_security_group.security_group_id
  ]

  endpoint_private_access = true
  endpoint_public_access  = false
  node_groups             = var.eks_node_groups

  additional_tags = var.additional_tags
}
