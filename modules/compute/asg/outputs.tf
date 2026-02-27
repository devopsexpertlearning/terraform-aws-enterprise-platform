output "asg_id" {
  description = "The ID of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.id
}

output "asg_name" {
  description = "The name of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.arn
}

output "asg_min_size" {
  description = "The minimum size of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.min_size
}

output "asg_max_size" {
  description = "The maximum size of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.max_size
}

output "asg_desired_capacity" {
  description = "The desired capacity of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.desired_capacity
}
