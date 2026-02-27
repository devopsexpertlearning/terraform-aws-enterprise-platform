# Centralized S3 Logging Bucket for flow logs and CloudTrail
resource "aws_s3_bucket" "central_logging" {
  bucket = "${var.project_name}-central-logs-${var.environment}"
}

resource "aws_s3_bucket_versioning" "central_logging" {
  bucket = aws_s3_bucket.central_logging.id
  versioning_configuration {
    status = "Enabled"
  }
}

# KMS Key for Log Encryption
resource "aws_kms_key" "log_encryption" {
  description             = "KMS Key for Central Logs Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudTrail to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "kms:GenerateDataKey*"
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "log_encryption" {
  name          = "alias/central-logs-${var.environment}"
  target_key_id = aws_kms_key.log_encryption.key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "central_logging" {
  bucket = aws_s3_bucket.central_logging.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.log_encryption.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "central_logging" {
  bucket                  = aws_s3_bucket.central_logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "central_logging" {
  bucket = aws_s3_bucket.central_logging.id

  rule {
    id     = "archive-logs-after-90-days"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555 # 7 years compliance
    }
  }
}

# Organization CloudTrail
resource "aws_cloudtrail" "org_trail" {
  name                          = "${var.project_name}-org-trail"
  s3_bucket_name                = aws_s3_bucket.central_logging.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.log_encryption.arn

  # In a real enterprise, this is `true` but requires running from the management account.
  is_organization_trail = var.is_org_trail

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_policy
  ]
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.central_logging.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck20150319"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.central_logging.arn
      },
      {
        Sid    = "AWSCloudTrailWrite20150319"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.central_logging.arn}/cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
