data "aws_region" "current" {}

resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  route_table_ids = [for rtbl in aws_route_table.private_route_tables : rtbl.id]
  policy = jsonencode({
    Statement = [{
      Action    = "*"
      Resource  = "*"
      Effect    = "Allow"
      Principal = "*"
    }]
    Version = "2012-10-17"
  })
  service_name = format("com.amazonaws.%s.dynamodb", data.aws_region.current.id)
  vpc_id       = aws_vpc.this.id
  tags         = merge(local.tags, { Name = format("%s-ddb-vpce", var.prefix) })
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  route_table_ids = [for rtbl in aws_route_table.private_route_tables : rtbl.id]
  policy = jsonencode({
    Statement = [{
      Action    = "*"
      Resource  = "*"
      Effect    = "Allow"
      Principal = "*"
    }]
    Version = "2012-10-17"
  })
  service_name = format("com.amazonaws.%s.s3", data.aws_region.current.id)
  vpc_id       = aws_vpc.this.id
  tags         = merge(local.tags, { Name = format("%s-s3-vpce", var.prefix) })
}


resource "aws_vpc_endpoint" "interface_endpoints" {
  count             = length(local.interface_vpces)
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_default_security_group.this.id
  ]
  policy = jsonencode({
    Statement = [{
      Action    = "*"
      Resource  = "*"
      Effect    = "Allow"
      Principal = "*"
    }]
    Version = "2012-10-17"
  })
  service_name = format("com.amazonaws.%s.%s", data.aws_region.current.id, local.interface_vpces[count.index])
  vpc_id       = aws_vpc.this.id
  tags         = merge(local.tags, { Name = format("%s-%s-vpce", var.prefix, local.interface_vpces[count.index]) })
}
