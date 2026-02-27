output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = data.aws_organizations_organization.main.id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization."
  value       = data.aws_organizations_organization.main.arn
}

output "organization_master_account_id" {
  description = "The master account ID."
  value       = data.aws_organizations_organization.main.master_account_id
}

output "organizational_unit_id" {
  description = "The ID of the Organizational Unit."
  value       = aws_organizations_organizational_unit.main.id
}

output "organizational_unit_arn" {
  description = "The ARN of the Organizational Unit."
  value       = aws_organizations_organizational_unit.main.arn
}
