output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC."
  value       = aws_vpc.main.arn
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "List of IDs of isolated subnets."
  value       = aws_subnet.isolated[*].id
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables."
  value       = aws_route_table.private[*].id
}

output "isolated_route_table_ids" {
  description = "List of IDs of isolated route tables."
  value       = aws_route_table.isolated[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT gateways."
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_ips" {
  description = "List of Elastic IPs associated with NAT gateways."
  value       = aws_eip.nat[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = var.enable_internet_gateway ? aws_internet_gateway.main[0].id : ""
}

output "transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway VPC attachment."
  value       = var.transit_gateway_id != "" ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : ""
}

output "vpc_flow_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = var.enable_vpc_flow_logs && var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : ""
}

output "availability_zones" {
  description = "List of availability zones used."
  value       = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names
}
