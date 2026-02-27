resource "aws_flow_log" "main" {
  log_destination      = var.log_destination_arn
  log_destination_type = var.log_destination_type
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-network-vpc-flow-log"
  }
}
