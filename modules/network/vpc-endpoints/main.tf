# Security group for endpoints to allow traffic only from VPC CIDR
resource "aws_security_group" "endpoints" {
  name        = "${var.project_name}-${var.environment}-network-vpc-endpoints-sg-01"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound (Deny managed elsewhere if needed)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-network-vpc-endpoint-sg-01"
  })
}

data "aws_region" "current" {}

# Gateway Endpoints (Free)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-network-vpc-endpoint-s3"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-network-vpc-endpoint-dynamodb"
  })
}

# Interface Endpoints (Paid - critical for internal security)
locals {
  endpoints = {
    "ecr.api" = {
      name = "ecr.api"
    },
    "ecr.dkr" = {
      name = "ecr.dkr"
    },
    "logs" = {
      name = "logs"
    },
    "kms" = {
      name = "kms"
    },
    "ssm" = {
      name = "ssm"
    },
    "ssmmessages" = {
      name = "ssmmessages"
    },
    "ec2messages" = {
      name = "ec2messages"
    },
    "secretsmanager" = {
      name = "secretsmanager"
    }
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = var.enable_interface_endpoints ? local.endpoints : {}
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value.name}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-network-vpc-endpoint-${replace(each.key, ".", "-")}"
  })
}
