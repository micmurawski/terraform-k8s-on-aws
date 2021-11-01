locals {
  tags = {
    project_name = var.project_name
    environment  = var.environment
  }

  public_subnets = [
    for x in range(var.num_public_subnets) : { cidr = cidrsubnet(cidrsubnet(var.cidr, 2, 0), 6, x), availability_zone = data.aws_availability_zones.available.names[x] }
  ]
  private_subnets = [
    for x in range(var.num_private_subnets) : { cidr = cidrsubnet(cidrsubnet(var.cidr, 2, 1), 6, x), availability_zone = data.aws_availability_zones.available.names[x] }
  ]

}