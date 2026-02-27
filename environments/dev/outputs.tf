output "vpc_id" {
  description = "VPC ID for this environment."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "kms_key_arn" {
  description = "Primary KMS key ARN used by modules."
  value       = module.ec2_kms.key_arn
}

output "ec2_instance_id" {
  description = "EC2 instance ID from compute/ec2 module."
  value       = module.app_server.instance_id
}

output "asg_name" {
  description = "ASG name from compute/asg module."
  value       = module.asg.asg_name
}

output "launch_template_id" {
  description = "Launch template ID from compute/launch-template module."
  value       = module.launch_template.launch_template_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.ecs_cluster_name
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN."
  value       = module.lambda.lambda_function_arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint."
  value       = module.rds.db_instance_endpoint
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster writer endpoint."
  value       = module.aurora.cluster_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = module.dynamodb.table_name
}

output "elasticache_primary_endpoint" {
  description = "ElastiCache primary endpoint."
  value       = module.elasticache.primary_endpoint_address
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = module.alb.alb_dns_name
}

output "nlb_dns_name" {
  description = "NLB DNS name."
  value       = module.nlb.nlb_dns_name
}

output "route53_zone_id" {
  description = "Route53 zone ID."
  value       = module.route53_zone.zone_id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN."
  value       = module.cloudtrail.cloudtrail_arn
}

output "sns_topic_arn" {
  description = "SNS alerts topic ARN."
  value       = module.sns_alerts.topic_arn
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN."
  value       = module.waf.web_acl_arn
}

output "secrets_manager_arn" {
  description = "DB secret ARN."
  value       = module.db_secret.secret_arn
}

output "efs_id" {
  description = "EFS file system ID."
  value       = module.efs.efs_id
}

output "ebs_volume_id" {
  description = "Standalone EBS volume ID."
  value       = module.ebs.ebs_volume_id
}
