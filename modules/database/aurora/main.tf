data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.password_secret_arn
}

resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project_name}-${var.environment}-${var.cluster_identifier}"

  engine               = var.engine
  engine_version       = var.engine_version
  database_name        = var.database_name
  master_username      = var.master_username
  master_password      = data.aws_secretsmanager_secret_version.db_password.secret_string
  db_subnet_group_name = aws_db_subnet_group.main.name

  engine_mode = var.serverlessv2_scaling_configuration != null ? "provisioned" : "provisioned"

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverlessv2_scaling_configuration != null ? [var.serverlessv2_scaling_configuration] : []

    content {
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }
  }

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_arn != "" ? var.kms_key_arn : null

  vpc_security_group_ids = var.vpc_security_group_ids

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : (
    var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-${var.cluster_identifier}-final"
  )

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  performance_insights_enabled = var.performance_insights_enabled

  global_cluster_identifier = var.global_cluster_identifier != "" ? var.global_cluster_identifier : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_identifier}"
  })

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-${var.cluster_identifier}-sng"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_identifier}-sng"
  })
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.instances.writer

  identifier          = "${var.project_name}-${var.environment}-${var.cluster_identifier}-writer-${format("%02d", count.index + 1)}"
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.main.engine
  engine_version      = aws_rds_cluster.main.engine_version
  publicly_accessible = false

  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_identifier}-writer-${format("%02d", count.index + 1)}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "reader" {
  count = var.instances.reader

  identifier          = "${var.project_name}-${var.environment}-${var.cluster_identifier}-reader-${format("%02d", count.index + 1)}"
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.main.engine
  engine_version      = aws_rds_cluster.main.engine_version
  publicly_accessible = false

  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_identifier}-reader-${format("%02d", count.index + 1)}"
  })

  lifecycle {
    create_before_destroy = true
  }
}
