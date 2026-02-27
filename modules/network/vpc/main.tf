data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-igw"
  })
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = length(var.availability_zones) > 0 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name                     = "${local.standard_name_prefix}-network-public-subnet-${format("%02d", count.index + 1)}"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = length(var.availability_zones) > 0 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name                              = "${local.standard_name_prefix}-network-private-subnet-${format("%02d", count.index + 1)}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "isolated" {
  count             = length(var.isolated_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = length(var.availability_zones) > 0 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-isolated-subnet-${format("%02d", count.index + 1)}"
  })
}

resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-nat-eip-${format("%02d", count.index + 1)}"
  })
}

resource "aws_nat_gateway" "main" {
  count = length(var.private_subnet_cidrs) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-nat-gateway-${format("%02d", count.index + 1)}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-public-route-table"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-private-route-table-${format("%02d", count.index + 1)}"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "isolated" {
  count = length(var.isolated_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-isolated-route-table-${format("%02d", count.index + 1)}"
  })
}

resource "aws_route_table_association" "isolated" {
  count          = length(var.isolated_subnet_cidrs)
  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolated[count.index].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.transit_gateway_id != "" ? 1 : 0

  subnet_ids         = aws_subnet.private[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main.id
  dns_support        = "enable"
  ipv6_support       = "disable"

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-tgw-attachment"
  })
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs && var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = var.vpc_flow_logs_log_group_name != "" ? var.vpc_flow_logs_log_group_name : "${local.standard_name_prefix}-network-vpc-flow-log-group"
  retention_in_days = 90

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-vpc-flow-log-group"
  })
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  count = var.enable_vpc_flow_logs && var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs && var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.vpc_flow_logs[0].arn,
      "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
    ]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs && var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name               = "${local.standard_name_prefix}-network-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role[0].json

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-vpc-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs && var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name   = "${local.standard_name_prefix}-network-vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_logs[0].id
  policy = data.aws_iam_policy_document.vpc_flow_logs[0].json
}

resource "aws_flow_log" "main" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  log_destination      = var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.vpc_flow_logs[0].arn : var.vpc_flow_logs_s3_bucket_arn
  log_destination_type = var.vpc_flow_logs_destination_type
  iam_role_arn         = var.vpc_flow_logs_destination_type == "cloud-watch-logs" ? aws_iam_role.vpc_flow_logs[0].arn : null
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  dynamic "destination_options" {
    for_each = var.vpc_flow_logs_destination_type == "s3" ? [1] : []

    content {
      file_format                = "parquet"
      hive_compatible_partitions = true
      per_hour_partition         = true
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.standard_name_prefix}-network-vpc-flow-log"
  })

  depends_on = [aws_iam_role_policy.vpc_flow_logs]
}
