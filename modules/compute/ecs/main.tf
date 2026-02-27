resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-${var.cluster_name}"

  dynamic "setting" {
    for_each = var.setting
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  dynamic "configuration" {
    for_each = var.cluster_configuration != null ? [var.cluster_configuration] : []

    content {
      dynamic "execute_command_configuration" {
        for_each = [configuration.value.execute_command_configuration]

        content {
          logging = execute_command_configuration.value.logging
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.cluster_configuration != null ? [var.cluster_configuration.service_connect_defaults] : []

    content {
      namespace = service_connect_defaults.value.namespace
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}"
  })
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  count = var.enable_fargate_capacity_providers ? 1 : 0

  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  count = var.cloudwatch_log_group_name != "" ? 1 : 0

  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_days

  kms_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}-log-group"
  })
}

resource "aws_ecs_service" "main" {
  count = var.service_definition != null ? 1 : 0

  name            = "${var.project_name}-${var.environment}-${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = var.service_definition.task_definition
  desired_count   = var.service_definition.desired_count
  launch_type     = var.service_definition.launch_type

  dynamic "network_configuration" {
    for_each = var.service_definition.network_configuration != null ? [var.service_definition.network_configuration] : []

    content {
      subnets          = network_configuration.value.subnets
      security_groups  = network_configuration.value.security_groups
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.service_definition.load_balancer != null ? [var.service_definition.load_balancer] : []

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}-service"
  })
}
