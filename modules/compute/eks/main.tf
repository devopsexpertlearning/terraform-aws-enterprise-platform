resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-${var.cluster_name}"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.vpc_security_group_ids
  }

  dynamic "encryption_config" {
    for_each = var.kms_key_arn != "" ? [1] : []

    content {
      resources = ["secrets"]
      provider {
        key_arn = var.kms_key_arn
      }
    }
  }

  enabled_cluster_log_types = var.cluster_enabled_log_types

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}"
  })

  lifecycle {
    ignore_changes = [version]
  }

  depends_on = [aws_cloudwatch_log_group.eks_cluster]
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  count = var.enable_eks_cluster_log_to_cloudwatch ? 1 : 0

  name              = "/aws/eks/${var.project_name}-${var.environment}-${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  kms_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}-log-group"
  })
}

data "tls_certificate" "eks" {
  count = var.enable_irsa ? 1 : 0
  url   = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}-oidc-provider"
  })
}

resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-${var.cluster_name}-${each.key}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size

  labels = merge(
    {
      workload = each.key
    },
    each.value.labels
  )

  dynamic "taint" {
    for_each = each.value.taints

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  ami_type = try(each.value.ami_type, "AL2_x86_64")

  release_version = try(each.value.ami_release_version, null)

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.cluster_name}-${each.key}"
  })

  depends_on = [
    aws_eks_cluster.main
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ec2_tag" "eks_cluster_security_group_name" {
  resource_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  key         = "Name"
  value       = "${var.project_name}-${var.environment}-${var.cluster_name}-cluster-sg-01"
}
