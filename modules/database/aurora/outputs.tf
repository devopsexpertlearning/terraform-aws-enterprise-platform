output "cluster_endpoint" {
  description = "The cluster endpoint for the writer."
  value       = aws_rds_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  description = "The cluster endpoint for the reader."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cluster_arn" {
  description = "The ARN of the cluster."
  value       = aws_rds_cluster.main.arn
}

output "cluster_id" {
  description = "The ID of the cluster."
  value       = aws_rds_cluster.main.id
}

output "cluster_resource_id" {
  description = "The resource ID of the cluster."
  value       = aws_rds_cluster.main.cluster_resource_id
}

output "cluster_name" {
  description = "The database name."
  value       = aws_rds_cluster.main.database_name
}
