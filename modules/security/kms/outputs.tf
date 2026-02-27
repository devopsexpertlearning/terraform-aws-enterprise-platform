output "key_id" {
  description = "The KMS key ID."
  value       = aws_kms_key.main.key_id
}

output "key_arn" {
  description = "The KMS key ARN."
  value       = aws_kms_key.main.arn
}

output "alias_name" {
  description = "The alias name of the KMS key."
  value       = var.alias_name != "" ? aws_kms_alias.main[0].name : ""
}
