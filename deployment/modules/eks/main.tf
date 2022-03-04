data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id"
}

resource "aws_eks_cluster" "this" {
  name                      = format("%s-eks-cluster", var.name)
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  tags                      = local.tags
  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    endpoint_private_access = true
    security_group_ids      = var.cluster_security_group_ids
    # vpc_id             = var.vpc_id
    subnet_ids = var.subnets_ids
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cidr
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy-attachment,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController-attachment,
  ]
}


resource "aws_eks_node_group" "eks_node_groups" {
  count           = length(var.subnets_ids)
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = format("%s-node-group-%s", var.name, count.index)
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids = [
    var.subnets_ids[count.index]
  ]
  tags = local.tags


  remote_access {
    ec2_ssh_key               = var.key_name
    source_security_group_ids = var.source_security_group_ids
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy-attachment,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy-attachment,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-attachment,
  ]
}


resource "aws_cloudwatch_log_group" "this" {
  name              = format("/aws/eks/%s/cluster", format("%s-eks-cluster", var.name))
  retention_in_days = 7
  tags              = local.tags
}
