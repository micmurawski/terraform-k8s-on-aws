resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  tags                 = merge(local.tags, { Name = format("%s-vpc", var.prefix) })
  enable_dns_support   = true
  enable_dns_hostnames = true

}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = format("%s-internet-gateway", var.prefix) })

}

resource "aws_nat_gateway" "nat_gateways" {
  count         = var.number_of_nat_gateways
  allocation_id = aws_eip.nat_gateway_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags          = merge(local.tags, { Name = format("%s-nat-gateway-%s", var.prefix, count.index) })
  depends_on = [
    aws_internet_gateway.this
  ]
}


resource "aws_subnet" "public_subnets" {
  count             = length(var.subnets_config["public"])
  vpc_id            = aws_vpc.this.id
  availability_zone = var.subnets_config["public"][count.index].availability_zone
  cidr_block        = var.subnets_config["public"][count.index].cidr
  tags              = merge(local.tags, { Name = format("%s-public-subnet-%s", var.prefix, count.index), Tier = "Public" })
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.subnets_config["private"])
  vpc_id            = aws_vpc.this.id
  availability_zone = var.subnets_config["private"][count.index].availability_zone
  cidr_block        = var.subnets_config["private"][count.index].cidr
  tags              = merge(local.tags, { Name = format("%s-private-subnet-%s", var.prefix, count.index), Tier = "Private" })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = format("%s-public-route-table", var.prefix) })
}

resource "aws_route_table" "private_route_tables" {
  count  = var.number_of_nat_gateways
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = format("%s-private-route-table-%s", var.prefix, count.index) })
}

resource "aws_route_table_association" "public_subnet_route_table_associations" {
  count          = length(aws_subnet.public_subnets)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table_association" "private_subnet_route_table_associations" {
  count          = length(aws_subnet.private_subnets)
  route_table_id = aws_route_table.private_route_tables[count.index % var.number_of_nat_gateways].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_route" "default_route_public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "default_routes_private" {
  count                  = var.number_of_nat_gateways
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateways[count.index].id
  route_table_id         = aws_route_table.private_route_tables[count.index].id
}

resource "aws_eip" "nat_gateway_eips" {
  count = var.number_of_nat_gateways
  vpc   = true
  tags  = merge(local.tags, { Name = format("%s-nat-gateway-eip-%s", var.prefix, count.index) })
  depends_on = [
    aws_internet_gateway.this
  ]

}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = format("%s-default-security-group", var.prefix) })

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self             = true
      description      = "egress"
      prefix_list_ids  = []
      security_groups  = []
    }
  ]

  ingress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self             = true
      description      = "ingress"
      prefix_list_ids  = []
      security_groups  = []
    }
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.flow_logs ? 1 : 0
  name  = format("%s-vpc-flow-logs-%s", var.prefix, count.index)
  tags  = local.tags
}

resource "aws_flow_log" "this" {
  count           = var.flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role[0].arn
  log_destination = aws_cloudwatch_log_group.this[count.index].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
  tags            = local.tags
}


