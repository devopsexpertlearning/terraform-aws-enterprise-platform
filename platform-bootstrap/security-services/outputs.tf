output "cloudtrail_bucket_name" {
  value       = aws_s3_bucket.cloudtrail_logs.bucket
  description = "The name of the S3 bucket for CloudTrail logs."
}

output "cloudtrail_bucket_arn" {
  value       = aws_s3_bucket.cloudtrail_logs.arn
  description = "The ARN of the S3 bucket for CloudTrail logs."
}

output "cloudtrail_kms_key_arn" {
  value       = aws_kms_key.cloudtrail.arn
  description = "The ARN of the KMS key for CloudTrail encryption."
}

output "cloudtrail_role_arn" {
  value       = aws_iam_role.cloudtrail_role.arn
  description = "The ARN of the IAM role for CloudTrail."
}

output "cloudtrail_arn" {
  value       = aws_cloudtrail.main.arn
  description = "The ARN of the CloudTrail trail."
}

output "guardduty_detector_id" {
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
  description = "The ID of the GuardDuty detector."
}

output "terraform_ci_cd_role_arn" {
  value       = aws_iam_role.terraform_ci_cd.arn
  description = "The ARN of the IAM role for Terraform CI/CD."
}

output "cross_account_readonly_role_arn" {
  value       = aws_iam_role.cross_account_readonly.arn
  description = "The ARN of the cross-account readonly role."
}
