resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name          = "${var.project_name}-${var.environment}-${var.alarm_name}"
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  alarm_description   = "Enterprise alarm: ${var.alarm_name} in ${var.environment}"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = var.dimensions

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.alarm_name}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
