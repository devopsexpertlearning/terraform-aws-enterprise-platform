data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "default_key_policy" {
  count = var.policy == "" ? 1 : 0

  statement {
    sid     = "Enable IAM User Permissions"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.key_user_arns) > 0 ? [1] : []

    content {
      sid    = "Allow use of key"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:CreateGrant"
      ]
      principals {
        type        = "AWS"
        identifiers = var.key_user_arns
      }
      resources = ["*"]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogsUseOfKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    }
  }

  statement {
    sid    = "AllowCloudTrailUseOfKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "main" {
  description             = var.description
  key_usage               = var.key_usage
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  policy = var.policy != "" ? var.policy : data.aws_iam_policy_document.default_key_policy[0].json

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-security-kms-key"
  })
}

resource "aws_kms_alias" "main" {
  count = var.alias_name != "" ? 1 : 0

  name          = var.alias_name
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_kms_grant" "main" {
  for_each = { for grant in var.grants : grant.name => grant }

  name              = each.value.name
  key_id            = aws_kms_key.main.key_id
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations
}
