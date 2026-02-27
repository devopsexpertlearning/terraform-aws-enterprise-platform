resource "aws_launch_template" "main" {
  name          = "${var.project_name}-${var.environment}-${var.name}"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  vpc_security_group_ids = var.vpc_security_group_ids

  user_data = var.user_data != null ? base64encode(var.user_data) : null

  iam_instance_profile {
    arn = var.iam_instance_profile != "" ? var.iam_instance_profile : null
  }

  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  ebs_optimized = var.enable_ebs_optimized

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = var.root_volume_type
      volume_size           = var.root_volume_size
      iops                  = var.root_volume_iops
      throughput            = var.root_volume_throughput
      encrypted             = true
      kms_key_id            = var.kms_key_arn != "" ? var.kms_key_arn : null
      delete_on_termination = true
    }
  }

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []

    content {
      market_type = instance_market_options.value.market_type

      spot_options {
        max_price                      = instance_market_options.value.spot_options.max_price
        instance_interruption_behavior = instance_market_options.value.spot_options.instance_interruption_behavior
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-${var.name}"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-${var.name}-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}
