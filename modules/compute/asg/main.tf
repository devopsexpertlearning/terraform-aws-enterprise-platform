resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-${var.environment}-${var.name}"
  vpc_zone_identifier = var.vpc_zone_identifier
  desired_capacity    = var.desired_capacity != null ? var.desired_capacity : var.min_size
  min_size            = var.min_size
  max_size            = var.max_size

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  default_cooldown          = var.default_cooldown
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group != "" ? var.placement_group : null

  enabled_metrics = var.enable_metrics_collection ? [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ] : []

  metrics_granularity = var.metrics_granularity

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_autoscaling_group_tag" "main" {
  for_each = { for idx, arn in var.target_group_arns : tostring(idx) => arn }

  tag {
    key                 = "aws:elasticbeanstalk:environment"
    value               = ""
    propagate_at_launch = false
  }

  autoscaling_group_name = aws_autoscaling_group.main.name
}
