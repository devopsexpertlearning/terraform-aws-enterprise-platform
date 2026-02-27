resource "aws_xray_sampling_rule" "main" {
  count          = var.enable_xray ? 1 : 0
  rule_name      = format("%s-%s", trimsuffix(substr(lower("${var.project_name}-${var.environment}-xray-rule"), 0, 23), "-"), substr(md5(lower("${var.project_name}-${var.environment}-xray-rule")), 0, 8))
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = var.sampling_rate
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  tags = {
    Name        = "${var.project_name}-${var.environment}-observability-xray-sampling-rule"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
