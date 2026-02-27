resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-${var.environment}-${var.name}"
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold_count
    unhealthy_threshold = var.unhealthy_threshold_count
    timeout             = var.health_check_timeout_seconds
    interval            = var.health_check_interval_seconds
    path                = var.health_check_path
    matcher             = "200-399"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })

  lifecycle {
    create_before_destroy = true
  }
}
