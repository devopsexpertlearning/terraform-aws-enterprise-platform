terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
  }

  cloudtrail_bucket_name = var.cloudtrail_log_bucket_name != "" ? var.cloudtrail_log_bucket_name : "${var.project_name}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudtrail_role" {
  name               = "${var.project_name}-cloudtrail-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudtrail_s3" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_kms_key" "cloudtrail" {
  description             = "KMS Key for CloudTrail encryption - ${var.project_name}-${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudtrail_kms_key_policy.json

  tags = local.common_tags
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.project_name}-cloudtrail-${var.environment}"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

data "aws_iam_policy_document" "cloudtrail_kms_key_policy" {
  statement {
    sid     = "Allow CloudTrail to use the key"
    effect  = "Allow"
    actions = ["kms:Encrypt*", "kms:Decrypt*", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:Describe*", "kms:CreateGrant"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:*:trail/*"]
    }
  }

  statement {
    sid     = "Allow root account full access"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = local.cloudtrail_bucket_name

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_logs.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_logs.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-cloudtrail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix                 = "cloudtrail/"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  tags = local.common_tags
}

resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  tags = local.common_tags
}

resource "aws_guardduty_filter" "s3_events" {
  count = var.enable_guardduty ? 1 : 0
  name  = "${var.project_name}-s3-events-${var.environment}"

  detector_id = aws_guardduty_detector.main[0].id
  action      = "ARCHIVE"
  rank        = 1

  finding_criteria {
    criterion {
      field  = "eventType"
      equals = ["S3DataEvent.S3PutObject"]
    }
  }
}

resource "aws_iam_role" "terraform_ci_cd" {
  name = "${var.project_name}-terraform-ci-cd-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codePipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "terraform_ci_cd_admin" {
  role       = aws_iam_role.terraform_ci_cd.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "cross_account_readonly" {
  name = "${var.project_name}-readonly-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cross_account_readonly" {
  role       = aws_iam_role.cross_account_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
