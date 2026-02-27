output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "The name of the S3 bucket storing the Terraform state."
}

output "dynamodb_table_name" {
  value       = var.create_dynamodb_lock_table ? aws_dynamodb_table.terraform_state_lock[0].name : null
  description = "The name of the DynamoDB table managing state locks (null when disabled)."
}

output "kms_key_arn" {
  value       = aws_kms_key.terraform_state.arn
  description = "The ARN of the KMS key encrypting the state bucket."
}
