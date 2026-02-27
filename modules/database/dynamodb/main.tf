resource "aws_dynamodb_table" "main" {
  name         = "${var.project_name}-${var.environment}-${var.table_name}"
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  table_class = var.table_class

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []

    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes

    content {
      hash_key        = global_secondary_index.value.hash_key
      name            = global_secondary_index.value.name
      projection_type = global_secondary_index.value.projection_type

      read_capacity  = global_secondary_index.value.read_capacity
      write_capacity = global_secondary_index.value.write_capacity
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes

    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.table_name}"
  })

  lifecycle {
    prevent_destroy = false
  }
}
