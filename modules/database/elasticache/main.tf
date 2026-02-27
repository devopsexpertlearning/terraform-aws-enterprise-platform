resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-${var.cluster_name}-sng"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}-sng"
  })
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project_name}-${var.environment}-${var.cluster_name}"
  description          = "ElastiCache ${var.engine} cluster"

  engine         = var.engine
  engine_version = var.engine_version
  node_type      = var.node_type

  num_cache_clusters = var.engine == "redis" ? null : var.num_cache_nodes
  num_node_groups    = var.engine == "redis" ? 1 : null

  replicas_per_node_group = (
    var.engine == "redis" && var.num_cache_nodes > 1 ? var.num_cache_nodes - 1 : null
  )

  parameter_group_name = var.parameter_group_name != "" ? var.parameter_group_name : null

  port                       = var.port
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.engine == "redis" ? var.automatic_failover_enabled : null

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  kms_key_id = var.at_rest_encryption_enabled && var.kms_key_id != "" ? var.kms_key_id : null

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_name            = var.snapshot_name != "" ? var.snapshot_name : null

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.security_group_ids

  dynamic "log_delivery_configuration" {
    for_each = var.engine == "redis" ? [1] : []

    content {
      destination      = aws_cloudwatch_log_group.elasticache_slow_log[0].name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "slow-log"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}"
  })

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "elasticache_slow_log" {
  count = var.engine == "redis" ? 1 : 0

  name              = "/aws/elasticache/${var.project_name}-${var.environment}-${var.cluster_name}/slow-log"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}-slow-log-group"
  })
}
