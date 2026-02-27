resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-${var.name}"
  internal           = var.internal
  load_balancer_type = "network"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })
}

resource "aws_lb_listener" "tcp" {
  count = var.target_group_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}
