locals {
  cluster_policies = ["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController", "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
  node_policies    = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  tags             = merge(var.tags, { Service = "eks" })
}


###################
### EKS Cluster ###
###################
resource "aws_eks_cluster" "this" {
  name     = local.tags["Name"]
  role_arn = aws_iam_role.cluster.arn
  version  = "1.32"

  vpc_config {
    subnet_ids                = var.subnet_ids
    cluster_security_group_id = aws_security_group.this.id
    endpoint_private_access   = true
    endpoint_public_access    = true
  }

  tags = merge(local.tags, { Resource = "eks" })
}

##############
# Cluster SG #
##############
resource "aws_security_group" "this" {
  name        = "${local.tags["Name"]}-${local.tags["Service"]}-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Resource = "sg" })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.this.id

  description = "Node group to cluster API"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

################
# Cluster role #
################
resource "aws_iam_role" "cluster" {
  name               = "${local.tags["Name"]}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster.json
  path               = "/GitOps/EKS/Cluster"

  tags = merge(local.tags, { Resource = "eks_cluster_iam_role" })
}

data "aws_iam_policy_document" "cluster" {
  statement {
    actions = ["sts:AsssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = toset(local.cluster_policies)

  policy_arn = each.key
  role       = aws_iam_role.cluster.id
}



######################
### EKS Node Group ###
######################
resource "aws_eks_node_group" "this" {
  cluster_name  = aws_eks_cluster.this.name
  node_role_arn = aws_iam_role.node.arn
  subnet_ids    = var.subnet_ids

  node_group_name = "GitOps-EKS-node-group"
  ami_type        = "AL2_x86_64"
  instance_types  = ["t3.small"]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  tags = merge(local.tags, { Resource = "eks_node_group" })
}

############
# IAM Role #
############

data "aws_iam_policy_document" "node" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${local.tags["Name"]}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.node.json
  path               = "/GitOps/EKS/Node"

  tags = merge(local.tags, { Resource = "eks_node_iam_role" })
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset(local.node_policies)

  role       = aws_iam_role.node.id
  policy_arn = each.key
}