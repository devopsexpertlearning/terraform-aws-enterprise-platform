resource "aws_s3_bucket" "logging" {
  count  = var.target_bucket_arn == "" ? 1 : 0
  bucket = var.bucket_name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-logging-s3-bucket"
  })
}

resource "aws_s3_bucket_versioning" "logging" {
  count  = var.target_bucket_arn == "" ? 1 : 0
  bucket = var.target_bucket_arn == "" ? aws_s3_bucket.logging[0].id : var.target_bucket_arn

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  count  = var.target_bucket_arn == "" ? 1 : 0
  bucket = var.target_bucket_arn == "" ? aws_s3_bucket.logging[0].id : var.target_bucket_arn

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  count  = var.target_bucket_arn == "" && length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = var.target_bucket_arn == "" ? aws_s3_bucket.logging[0].id : var.target_bucket_arn

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      filter {}

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}
