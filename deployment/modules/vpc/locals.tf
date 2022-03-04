locals {
  tags            = merge(var.tags, { module = "vpc" })
  interface_vpces = ["kms", "ec2", "logs", "ecr.api", "ecr.dkr", "sts"]
}