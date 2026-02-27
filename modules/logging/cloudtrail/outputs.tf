output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail."
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_id" {
  description = "The ID of the CloudTrail."
  value       = aws_cloudtrail.main.id
}
