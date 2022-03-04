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
  source    = "./modules/vpc"
  prefix    = local.prefix
  flow_logs = false
  tags      = local.tags
  subnets_config = {
    public  = local.public_subnets
    private = local.private_subnets
  }
}

resource "aws_key_pair" "this" {
  key_name   = format("%s-key-pair", local.prefix)
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

  tags = merge(local.tags, { Name = format("%s-bastion", local.prefix) })
}

module "eks-cluster" {
  source        = "./modules/eks"
  name          = format("%s-eks", local.prefix)
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


### SSM PARAMETERS

resource "aws_ssm_parameter" "api_url" {
  name  = format("%s/%s/vpc_id", var.project_name, var.environment)
  value = module.vpc.vpc_id
}
