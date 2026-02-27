output "db_instance_id" {
  description = "The ID of the RDS instance."
  value       = aws_db_instance.main.id
}

output "db_instance_address" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.main.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance (includes port)."
  value       = aws_db_instance.main.endpoint
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.main.arn
}

output "db_instance_name" {
  description = "The database name."
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  value       = aws_db_subnet_group.main.name
}

output "db_instance_port" {
  description = "The port of the RDS instance."
  value       = aws_db_instance.main.port
}
