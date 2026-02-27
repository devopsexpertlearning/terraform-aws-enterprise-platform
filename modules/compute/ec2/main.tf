data "aws_subnet" "selected" {
  id = var.subnet_id
}

locals {
  sorted_additional_ebs_volume_keys = sort(keys(var.additional_ebs_volumes))

  additional_ebs_volumes_by_index = {
    for idx, volume_key in local.sorted_additional_ebs_volume_keys :
    format("%02d", idx + 1) => merge(var.additional_ebs_volumes[volume_key], { source_key = volume_key })
  }
}

resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null

  user_data_base64 = var.user_data_base64 != null ? var.user_data_base64 : (
    var.user_data != null ? base64encode(var.user_data) : null
  )

  ebs_optimized = var.enable_ebs_optimized

  metadata_options {
    http_endpoint               = var.enable_instance_metadata_service ? "enabled" : "disabled"
    http_tokens                 = var.instance_metadata_tokens
    http_put_response_hop_limit = var.instance_metadata_hop_limit
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = true
    kms_key_id            = var.kms_key_arn != "" ? var.kms_key_arn : null
    delete_on_termination = true
  }

  associate_public_ip_address = var.associate_public_ip_address

  tenancy = var.tenancy

  disable_api_termination = var.termination_protection

  monitoring = var.monitoring_enabled

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ebs_volume" "additional" {
  for_each = local.additional_ebs_volumes_by_index

  availability_zone = data.aws_subnet.selected.availability_zone
  size              = each.value.size
  type              = each.value.type
  encrypted         = true
  kms_key_id        = each.value.kms_key_arn != "" ? each.value.kms_key_arn : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}-ebs-${each.key}"
  })
}

resource "aws_volume_attachment" "additional" {
  for_each = local.additional_ebs_volumes_by_index

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.additional[each.key].id
  instance_id = aws_instance.main.id
}
