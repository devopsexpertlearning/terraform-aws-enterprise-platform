resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = var.name
  type    = var.type
  ttl     = var.alias != null ? null : var.ttl
  records = var.alias != null ? null : var.records

  dynamic "alias" {
    for_each = var.alias != null ? [var.alias] : []

    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  set_identifier = var.set_identifier != "" ? var.set_identifier : null

  health_check_id = var.health_check_id != "" ? var.health_check_id : null

  lifecycle {
    create_before_destroy = true
  }
}
