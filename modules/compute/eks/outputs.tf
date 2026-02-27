output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS API server."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "The ARN of the IAM OIDC Provider for IRSA."
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.eks[0].arn : null
}

output "oidc_provider_url" {
  description = "The URL of the IAM OIDC Provider for IRSA."
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "The cluster security group created by EKS."
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_group_ids" {
  description = "Map of node group IDs."
  value       = { for k, v in aws_eks_node_group.main : k => v.id }
}

output "node_group_arns" {
  description = "Map of node group ARNs."
  value       = { for k, v in aws_eks_node_group.main : k => v.arn }
}

output "cluster_version" {
  description = "The Kubernetes version of the cluster."
  value       = aws_eks_cluster.main.version
}

output "cluster_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group."
  value       = var.enable_eks_cluster_log_to_cloudwatch ? aws_cloudwatch_log_group.eks_cluster[0].name : null
}
