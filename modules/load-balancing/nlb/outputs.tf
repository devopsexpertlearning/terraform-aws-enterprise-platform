output "nlb_arn" {
  description = "The ARN of the NLB."
  value       = aws_lb.main.arn
}

output "nlb_id" {
  description = "The ID of the NLB."
  value       = aws_lb.main.id
}

output "nlb_dns_name" {
  description = "The DNS name of the NLB."
  value       = aws_lb.main.dns_name
}
