output "security_group_id" {
  description = "The ID of the security group."
  value       = aws_security_group.main.id
}

output "security_group_arn" {
  description = "The ARN of the security group."
  value       = aws_security_group.main.arn
}

output "security_group_vpc_id" {
  description = "The VPC ID of the security group."
  value       = aws_security_group.main.vpc_id
}
