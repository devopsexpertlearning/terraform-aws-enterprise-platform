output "bucket_name" {
  description = "The name of the S3 logging bucket."
  value       = aws_s3_bucket.logging[0].bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 logging bucket."
  value       = aws_s3_bucket.logging[0].arn
}
