resource "aws_route53_zone" "main" {
  name          = var.zone_name
  comment       = var.comment
  force_destroy = var.force_destroy

  dynamic "vpc" {
    for_each = var.vpc_id != "" ? [var.vpc_id] : []

    content {
      vpc_id = vpc.value
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-dns-route53-zone"
  })
}
