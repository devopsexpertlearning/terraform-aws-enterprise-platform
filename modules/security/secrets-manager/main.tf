resource "aws_secretsmanager_secret" "main" {
  name                    = "${var.project_name}-${var.environment}-${replace(var.secret_name, "/", "-")}"
  description             = var.description
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${replace(var.secret_name, "/", "-")}"
  })
}

resource "aws_secretsmanager_secret_version" "main" {
  count         = var.secret_string != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string
}
