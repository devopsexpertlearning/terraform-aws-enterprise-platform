data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.password_secret_arn
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-${var.identifier}-sng"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.identifier}-sng"
  })
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-${var.identifier}"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  iops = var.storage_type == "gp3" && var.allocated_storage >= 400 ? var.iops : (
    var.storage_type == "io1" || var.storage_type == "io2" ? var.iops : 0
  )

  storage_throughput = var.storage_type == "gp3" && var.allocated_storage >= 400 ? var.storage_throughput : null

  db_name  = var.db_name
  username = var.username
  password = data.aws_secretsmanager_secret_version.db_password.secret_string

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : (
    var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-${var.identifier}-final"
  )

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitor.arn

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null

  ca_cert_identifier   = var.ca_cert_identifier
  parameter_group_name = var.parameter_group_name != "" ? var.parameter_group_name : null
  option_group_name    = var.option_group_name != "" ? var.option_group_name : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.identifier}"
  })

  lifecycle {
    prevent_destroy = false
  }
}

data "aws_iam_policy_document" "rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_monitor" {
  name               = "${var.project_name}-${var.environment}-${var.identifier}-monitor"
  assume_role_policy = data.aws_iam_policy_document.rds_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.identifier}-monitor-role"
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitor" {
  role       = aws_iam_role.rds_monitor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
