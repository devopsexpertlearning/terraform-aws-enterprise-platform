data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}-${var.bucket_name_suffix}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.bucket_name_suffix}"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
      sse_algorithm     = var.kms_key_arn != "" ? "aws:kms" : "AES256"
    }
    bucket_key_enabled = var.kms_key_arn != "" ? true : false
  }
}

# The enterprise baseline is strict: no public buckets allowed.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.lifecycle_rules_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "standard-ia-transition"
    status = "Enabled"
    filter {}

    transition {
      days          = var.transition_to_ia_days
      storage_class = "STANDARD_IA"
    }
  }
}
