resource "aws_cloudwatch_log_group" "main" {
  name              = "/${var.project_name}/${var.environment}/${var.log_group_name}"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.log_group_name}"
  })
}
