resource "aws_ebs_volume" "main" {
  availability_zone = var.availability_zone
  size              = var.size
  type              = var.type
  encrypted         = var.encrypted
  kms_key_id        = var.kms_key_arn != "" ? var.kms_key_arn : null
  snapshot_id       = var.snapshot_id != "" ? var.snapshot_id : null

  iops = contains(["io1", "io2", "gp3"], var.type) ? var.iops : null

  throughput = var.type == "gp3" ? var.throughput : null

  multi_attach_enabled = var.multi_attach_enabled && contains(["io1", "io2"], var.type) ? true : null

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.name}"
  })
}
