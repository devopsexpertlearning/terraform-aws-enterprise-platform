output "s3_endpoint_id" {
  description = "The ID of the S3 Gateway Endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "The ID of the DynamoDB Gateway Endpoint."
  value       = aws_vpc_endpoint.dynamodb.id
}

output "interface_endpoint_ids" {
  description = "Map of interface endpoint names to their IDs."
  value       = { for k, v in aws_vpc_endpoint.interface_endpoints : k => v.id }
}

output "endpoints_security_group_id" {
  description = "The Security Group ID attached to all interface endpoints."
  value       = aws_security_group.endpoints.id
}
