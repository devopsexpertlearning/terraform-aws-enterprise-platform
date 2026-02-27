output "sampling_rule_arn" {
  description = "The ARN of the X-Ray Sampling Rule."
  value       = var.enable_xray ? aws_xray_sampling_rule.main[0].arn : null
}
