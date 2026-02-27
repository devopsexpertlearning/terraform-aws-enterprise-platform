resource "aws_sns_topic" "main" {
  name              = "${var.project_name}-${var.environment}-${var.topic_name}"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.topic_name}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "main" {
  count     = length(var.subscription_endpoints)
  topic_arn = aws_sns_topic.main.arn
  protocol  = var.subscription_endpoints[count.index].protocol
  endpoint  = var.subscription_endpoints[count.index].endpoint
}
