data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  owners = ["099720109477"] # Canonical
}

module "vpc" {
  source         = "./vpc"
  prefix         = var.prefix
  flow_logs      = false
  tags           = local.tags
  subnets_config = var.subnets_config
}

resource "aws_key_pair" "this" {
  key_name   = format("%s-key-pair", var.prefix)
  public_key = file("${path.module}/id_rsa.pub")
  tags       = local.tags
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  security_groups = [
    module.vpc.default_security_group_id
  ]
  subnet_id = module.vpc.public_subnets_ids[0]

  tags = merge(local.tags, { Name = format("%s-bastion", var.prefix) })
}

module "airflow-eks-cluster" {
  source        = "./eks"
  name          = format("%s-af-eks", var.prefix)
  key_name      = aws_key_pair.this.key_name
  instance_type = "t2.micro"
  tags          = local.tags
  subnets_ids   = module.vpc.private_subnets_ids
  vpc_id        = module.vpc.vpc_id
  cluster_security_group_ids = [
    module.vpc.default_security_group_id
  ]
  source_security_group_ids = [
    module.vpc.default_security_group_id
  ]
}


##### PROXY API GW


##### COGNITO


##### ECS CLUSTER



#### POSTGRES 

