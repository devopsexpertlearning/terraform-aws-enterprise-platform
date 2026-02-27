resource "aws_security_group" "main" {
  name        = "${var.project_name}-${var.environment}-${var.name}"
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = length(try(each.value.cidr_blocks, [])) > 0 ? each.value.cidr_blocks : null
  self                     = try(each.value.self, false) ? true : null
  source_security_group_id = try(each.value.source_security_group_id, null)
  security_group_id        = aws_security_group.main.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = length(try(each.value.cidr_blocks, [])) > 0 ? each.value.cidr_blocks : null
  self                     = try(each.value.self, false) ? true : null
  source_security_group_id = try(each.value.source_security_group_id, null)
  security_group_id        = aws_security_group.main.id
  type                     = "egress"
}
