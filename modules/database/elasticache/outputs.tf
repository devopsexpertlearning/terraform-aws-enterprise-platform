output "replication_group_id" {
  description = "The ElastiCache replication group ID."
  value       = aws_elasticache_replication_group.main.id
}

output "replication_group_arn" {
  description = "The ARN of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "primary_endpoint_address" {
  description = "The primary endpoint address."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "The reader endpoint address."
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "port" {
  description = "The port number."
  value       = aws_elasticache_replication_group.main.port
}
