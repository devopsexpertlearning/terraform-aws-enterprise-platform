output "ebs_volume_id" {
  description = "The ID of the EBS volume."
  value       = aws_ebs_volume.main.id
}

output "ebs_volume_arn" {
  description = "The ARN of the EBS volume."
  value       = aws_ebs_volume.main.arn
}
