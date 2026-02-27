resource "aws_efs_file_system" "main" {
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_arn != "" ? var.kms_key_arn : null
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null
  performance_mode                = var.performance_mode

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })
}

resource "aws_efs_mount_target" "main" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_group_ids
}

resource "aws_efs_access_point" "main" {
  count = var.enable_access_point ? 1 : 0

  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = var.posix_user_gid
    uid = var.posix_user_uid
  }

  root_directory {
    path = var.access_point_path
    creation_info {
      owner_gid   = var.posix_user_gid
      owner_uid   = var.posix_user_uid
      permissions = var.access_point_permissions
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}-ap"
  })
}
