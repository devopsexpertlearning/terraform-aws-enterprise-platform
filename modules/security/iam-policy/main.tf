resource "aws_iam_policy" "main" {
  name        = "${var.project_name}-${var.environment}-${var.name}"
  path        = var.path
  description = var.description
  policy      = var.policy

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })
}
