output "role_id" {
  description = "The ID of the IAM role."
  value       = aws_iam_role.main.id
}

output "role_name" {
  description = "The name of the IAM role."
  value       = aws_iam_role.main.name
}

output "role_arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_role.main.arn
}
