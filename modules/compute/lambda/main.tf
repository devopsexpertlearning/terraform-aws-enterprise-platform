resource "aws_lambda_function" "main" {
  function_name                  = "${var.project_name}-${var.environment}-${var.function_name}"
  description                    = var.description
  package_type                   = var.package_type
  runtime                        = var.package_type == "Zip" ? var.runtime : null
  handler                        = var.package_type == "Zip" ? var.handler : null
  filename                       = var.package_type == "Zip" && var.filename != "" ? var.filename : null
  s3_bucket                      = var.package_type == "Zip" && var.filename == "" ? var.s3_bucket : null
  s3_key                         = var.package_type == "Zip" && var.filename == "" ? var.s3_key : null
  s3_object_version              = var.package_type == "Zip" && var.filename == "" && var.s3_object_version != "" ? var.s3_object_version : null
  image_uri                      = var.package_type == "Image" ? var.image_uri : null
  role                           = var.lambda_role_arn
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  source_code_hash               = var.package_type == "Zip" && var.filename != "" && var.source_code_hash != "" ? var.source_code_hash : null
  architectures                  = var.architectures
  kms_key_arn                    = var.kms_key_arn != "" ? var.kms_key_arn : null

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []

    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  environment {
    variables = var.environment_variables
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config != null ? [var.tracing_config] : []

    content {
      mode = tracing_config.value.mode
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config != null ? [var.dead_letter_config] : []

    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  layers = var.layers

  dynamic "file_system_config" {
    for_each = var.efs_mount_target != null ? [var.efs_mount_target] : []

    content {
      local_mount_path = var.efs_mount_target.value.local_mount_path
      arn              = var.efs_mount_target.value.arn
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.function_name}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_function_event_invoke_config" "main" {
  count = var.async_config != null ? 1 : 0

  function_name = aws_lambda_function.main.function_name
  qualifier     = aws_lambda_function.main.version

  dynamic "destination_config" {
    for_each = (
      try(var.async_config.destination_on_failure, null) != null ||
      try(var.async_config.destination_on_success, null) != null
    ) ? [1] : []

    content {
      dynamic "on_failure" {
        for_each = try(var.async_config.destination_on_failure, null) != null ? [1] : []
        content {
          destination = var.async_config.destination_on_failure
        }
      }

      dynamic "on_success" {
        for_each = try(var.async_config.destination_on_success, null) != null ? [1] : []
        content {
          destination = var.async_config.destination_on_success
        }
      }
    }
  }

  maximum_event_age_in_seconds = try(var.async_config.maximum_event_age_in_seconds, 3600)
  maximum_retry_attempts       = try(var.async_config.maximum_retry_attempts, 2)
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention_days

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.function_name}-log-group"
  })
}
