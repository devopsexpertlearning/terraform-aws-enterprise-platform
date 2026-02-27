output "central_logging_bucket_name" {
  value = aws_s3_bucket.central_logging.bucket
}

output "log_encryption_kms_key_arn" {
  value = aws_kms_key.log_encryption.arn
}
