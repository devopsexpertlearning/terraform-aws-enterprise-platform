output "topic_arn" {
  description = "The ARN of the SNS Topic."
  value       = aws_sns_topic.main.arn
}

output "topic_name" {
  description = "The name of the SNS Topic."
  value       = aws_sns_topic.main.name
}
