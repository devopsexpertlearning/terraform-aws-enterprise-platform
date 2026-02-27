resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-${var.dashboard_name}"
  dashboard_body = var.dashboard_body
}
