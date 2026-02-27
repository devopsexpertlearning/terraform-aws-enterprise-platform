output "efs_id" {
  description = "The ID of the EFS file system."
  value       = aws_efs_file_system.main.id
}

output "efs_arn" {
  description = "The ARN of the EFS file system."
  value       = aws_efs_file_system.main.arn
}

output "efs_dns_name" {
  description = "The DNS name of the EFS file system."
  value       = aws_efs_file_system.main.dns_name
}

output "mount_target_ids" {
  description = "List of mount target IDs."
  value       = aws_efs_mount_target.main[*].id
}
