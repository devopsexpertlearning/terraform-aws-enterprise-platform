resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.environment}-${var.name}"
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = lookup(ingress.value, "from_port", null)
      to_port         = lookup(ingress.value, "to_port", null)
      protocol        = lookup(ingress.value, "protocol", null)
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      self            = lookup(ingress.value, "self", null)
      description     = lookup(ingress.value, "description", null)
    }
  }

  dynamic "egress" {
    # If users provide no egress_rules, no egress is allowed (Deny by default behavior).
    # If they provide rules, bind them.
    for_each = var.egress_rules
    content {
      from_port       = lookup(egress.value, "from_port", 0)
      to_port         = lookup(egress.value, "to_port", 0)
      protocol        = lookup(egress.value, "protocol", "-1")
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      security_groups = lookup(egress.value, "security_groups", null)
      self            = lookup(egress.value, "self", null)
      description     = lookup(egress.value, "description", null)
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  }
}
