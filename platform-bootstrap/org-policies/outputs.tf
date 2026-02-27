output "deny_leaving_org_policy_id" {
  description = "The ID of the deny-leaving-org policy"
  value       = try(aws_organizations_policy.deny_leaving_org[0].id, "")
}

output "protect_security_services_policy_id" {
  description = "The ID of the protect-security-services policy"
  value       = try(aws_organizations_policy.protect_security_services[0].id, "")
}

output "all_policy_ids" {
  description = "List of all org policy IDs created"
  value = concat(
    aws_organizations_policy.deny_leaving_org[*].id,
    aws_organizations_policy.protect_security_services[*].id
  )
}
