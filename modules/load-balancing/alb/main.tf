resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-${var.name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields
  idle_timeout               = var.idle_timeout

  enable_http2 = var.enable_http2

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "access_logs" {
    for_each = var.enable_access_logs && var.access_logs_bucket != "" ? [1] : []

    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })
}

resource "aws_lb_listener" "http" {
  count = var.enable_http2 ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.default_ssl_certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.default_ssl_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_target_group" "default" {
  name = format(
    "%s-01",
    trimsuffix(substr(lower("${var.project_name}-${var.environment}-${var.name}-tg"), 0, 29), "-")
  )
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}-tg-01"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  count = var.waf_acl_arn != "" ? 1 : 0

  resource_arn = aws_lb.main.arn
  web_acl_arn  = var.waf_acl_arn
}
