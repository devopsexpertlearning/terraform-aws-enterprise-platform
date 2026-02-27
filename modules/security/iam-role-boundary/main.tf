resource "aws_iam_role" "main" {
  name                 = "${var.project_name}-${var.environment}-${var.role_name}"
  assume_role_policy   = var.assume_role_policy
  permissions_boundary = var.permissions_boundary_arn

  dynamic "inline_policy" {
    for_each = var.inline_policies
    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.role_name}"
  }
}

resource "aws_iam_role_policy_attachment" "managed" {
  count      = length(var.managed_policy_arns)
  role       = aws_iam_role.main.name
  policy_arn = var.managed_policy_arns[count.index]
}
