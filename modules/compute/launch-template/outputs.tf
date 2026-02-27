output "launch_template_id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template."
  value       = aws_launch_template.main.latest_version
}

output "launch_template_arn" {
  description = "The ARN of the launch template."
  value       = aws_launch_template.main.arn
}
