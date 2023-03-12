data "aws_eks_cluster" "cluster" {
  count = 1
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  count = 1
  name  = var.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true

  vpc_id     = "vpc-045742fef0eb917ca"
  subnet_ids = ["subnet-046cd28b75a57a334", "subnet-0ee390305504205db"]
  control_plane_subnet_ids= ["subnet-046cd28b75a57a334", "subnet-0ee390305504205db"]

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    force_update_version = false
  }

  eks_managed_node_groups = {
    default = {
      name         = "${var.cluster_name}-nodes"
      min_size     = 2
      max_size     = 4
      desired_size = 2
      subnet_ids = ["subnet-046cd28b75a57a334", "subnet-0ee390305504205db"]

      instance_types = [var.instance_types]
      ami_type = var.ami_type
      capacity_type  = "ON_DEMAND"
      attach_cluster_primary_security_group = true

    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::894516026745:role/AdministratorAccess"
      username = "admin"
      groups   = ["system:masters"]
    },
  ]
}
