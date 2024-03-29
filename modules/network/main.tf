# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  # VPC Basic Details
  name            = var.vpc_name
  cidr            = var.cidr_block
  azs             = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  default_security_group_ingress = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      self      = true
    },
    {
      from_port        = 443
      to_port          = 443
      protocol         = "TCP"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]

  default_security_group_egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Additional Tags to Subnets
  public_subnet_tags = {
    "Name"                   = "${var.vpc_name}-public"
    "tier"                   = "public"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "Name"                            = "${var.vpc_name}-private"
    "tier"                            = "private"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = merge(
    {
      "Name" = var.vpc_name
    },
    var.tags
  )

  vpc_tags = merge(
    {
      "Name" = var.vpc_name
    },
    var.tags
  )
  map_public_ip_on_launch = false
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "/vpc/flowlog/${var.vpc_name}"
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}

resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_s3_gateway ? 1 : 0
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${local.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.public_route_table_ids
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  count               = length(var.vpce_interface_services)
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${local.aws_region}.${var.vpce_interface_services[count.index]}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.vpc_name}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "vpc_flow_log_policy" {
  name        = "${var.vpc_name}-flow-log-policy"
  description = "Policy for VPC Flow Logs to publish to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
        ],
        Effect   = "Allow",
        Resource = aws_cloudwatch_log_group.vpc_flow_log.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_policy_attachment" {
  policy_arn = aws_iam_policy.vpc_flow_log_policy.arn
  role       = aws_iam_role.vpc_flow_log_role.name
}


resource "aws_ssm_parameter" "vpc_id" {
  name  = "/facts/v1/${var.vpc_name}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/facts/v1/${var.vpc_name}/private_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.private_subnets)
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/facts/v1/${var.vpc_name}/public_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.public_subnets)
}

resource "aws_ssm_parameter" "availability_zones" {
  name  = "/facts/v1/${var.vpc_name}/availability_zones"
  type  = "StringList"
  value = join(",", module.vpc.azs)
}
