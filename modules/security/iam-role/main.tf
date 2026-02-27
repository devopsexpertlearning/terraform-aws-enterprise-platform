resource "aws_iam_role" "main" {
  name               = "${var.project_name}-${var.environment}-${var.name}"
  path               = var.path
  assume_role_policy = var.assume_role_policy

  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policy

  permissions_boundary = var.permissions_boundary != "" ? var.permissions_boundary : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  for_each = { for idx, arn in var.policy_arns : tostring(idx) => arn }

  role       = aws_iam_role.main.name
  policy_arn = each.value
}

resource "aws_iam_policy" "inline" {
  count = var.inline_policy != "" ? 1 : 0

  name        = var.inline_policy_name != "" ? "${var.project_name}-${var.environment}-${var.inline_policy_name}" : "${var.project_name}-${var.environment}-${var.name}-policy"
  policy      = var.inline_policy
  description = "Inline policy for ${var.name} role"

  tags = merge(local.common_tags, {
    Name = var.inline_policy_name != "" ? "${var.project_name}-${var.environment}-${var.inline_policy_name}" : "${var.project_name}-${var.environment}-${var.name}-policy"
  })
}

resource "aws_iam_role_policy_attachment" "inline" {
  count = var.inline_policy != "" ? 1 : 0

  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.inline[0].arn
}
