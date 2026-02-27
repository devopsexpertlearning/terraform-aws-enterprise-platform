output "record_id" {
  description = "The ID of the Route 53 record."
  value       = aws_route53_record.main.id
}

output "record_fqdn" {
  description = "The FQDN of the record."
  value       = aws_route53_record.main.fqdn
}
