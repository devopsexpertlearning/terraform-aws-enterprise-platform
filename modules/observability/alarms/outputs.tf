output "alarm_arn" {
  description = "The ARN of the CloudWatch Alarm."
  value       = aws_cloudwatch_metric_alarm.main.arn
}

output "alarm_id" {
  description = "The ID of the CloudWatch Alarm."
  value       = aws_cloudwatch_metric_alarm.main.id
}
