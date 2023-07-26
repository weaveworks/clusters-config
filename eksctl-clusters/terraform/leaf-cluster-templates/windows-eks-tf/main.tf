data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

##################################################################
# VPC
##################################################################
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

##################################################################
# EKS cluster
##################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"
  #version = "19.15.3"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  #cluster_endpoint_public_access = false

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    force_update_version = false
  }

  eks_managed_node_groups = {
    linux = {
      name         = "${var.cluster_name}-linux"
      min_size     = 1
      max_size     = 4
      desired_size = 1
      subnet_ids   = module.vpc.private_subnets

      instance_types                        = [var.instance_types]
      ami_type                              = var.linux_ami_type
      capacity_type                         = "ON_DEMAND"
      attach_cluster_primary_security_group = true

    }

    windows = {
      name         = "${var.cluster_name}-windows"
      platform     = "windows"
      min_size     = 1
      max_size     = 3
      desired_size = 1
      subnet_ids   = module.vpc.private_subnets

      instance_types                        = [var.instance_types]
      ami_type                              = var.ami_type
      capacity_type                         = "ON_DEMAND"
      attach_cluster_primary_security_group = true

    }
  }

  # aws-auth configmap
  # manage_aws_auth_configmap = true
  # aws_auth_roles = [{ groups = ["system:masters"], rolearn = "arn:aws:iam::007640530078:role/AWSReservedSSO_AdministratorAccess_5d7d52bae0c5bf1f", username = "adminuser:{{SessionName}}" },]
}

resource "kubectl_manifest" "aws_auth" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapAccounts: |
    []
  mapRoles: |
    - groups:
      - "system:bootstrappers"
      - "system:nodes"
      "rolearn": "${module.eks.eks_managed_node_groups.linux.iam_role_arn}"
      "username": "system:node:{{EC2PrivateDNSName}}"
    - groups:
      - "system:bootstrappers"
      - "system:nodes"
      - "eks:kube-proxy-windows"
      "rolearn": "${module.eks.eks_managed_node_groups.windows.iam_role_arn}"
      "username": "system:node:{{EC2PrivateDNSName}}"
    - groups:
      - "system:masters"
      "rolearn": "arn:aws:iam::007640530078:role/AWSReservedSSO_AdministratorAccess_5d7d52bae0c5bf1f"
      "username": "adminuser:{{SessionName}}"
  mapUsers: |
    []
  YAML
}

# ##################################################################
# # Kubeconfig
# ##################################################################

module "leaf_config" {
  source                 = "../../modules/leaf-kubeconfig"
  cluster_name           = var.cluster_name
  cluster_ca_certificate = data.aws_eks_cluster.this.certificate_authority[0].data
  cluster_endpoint       = data.aws_eks_cluster.this.endpoint
  commit_author          = var.git_commit_author
  commit_email           = var.git_commit_email
  # github_owner           = "caseware"
  # repository_name        = "eks-wge-management-cwcloudtest"
  github_owner           = "weaveworks"
  repository_name        = "clusters-config"
  branch                 = "saeed-case"
}

#Below added by Paulo F.
#resource "kubernetes_config_map" "amazon_vpc_cni" {
  #metadata {
    #name      = "amazon-vpc-cni"
    #namespace = "kube-system"
  #}

  #data = {
    #enable-windows-ipam = "true"
  #}
#}
