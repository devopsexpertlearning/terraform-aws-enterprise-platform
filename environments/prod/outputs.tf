output "vpc_id" {
  description = "VPC ID for this environment."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "app_security_group_id" {
  description = "Application security group ID."
  value       = module.app_security_group.security_group_id
}

output "instance_id" {
  description = "Application EC2 instance ID."
  value       = module.app_server.instance_id
}

output "instance_private_ip" {
  description = "Application EC2 private IP."
  value       = module.app_server.private_ip
}

output "kms_key_arn" {
  description = "Customer-managed KMS key ARN (if enabled)."
  value       = var.enable_customer_managed_kms ? module.ec2_kms[0].key_arn : null
}
