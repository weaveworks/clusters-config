terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "cluster_name" {}
variable "cluster_version" {}
variable "instance_types" {}
variable "ami_type" {}
variable "region" {default= "eu-north-1"}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_role_arn" {}


provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  assume_role {
    role_arn    = var.aws_role_arn
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

################################################################################
# VPC
################################################################################


################################################################################
# EKS Cluster
################################################################################
data "aws_eks_cluster" "cluster" {
  count = 1
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = 1
  name  = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true

  vpc_id     = "vpc-0317580fde8817c2a"
  subnet_ids = ["subnet-0b836507495991415", "subnet-0cb479c06a51a041d"]
  control_plane_subnet_ids= ["subnet-0b836507495991415", "subnet-0cb479c06a51a041d"]

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
      subnet_ids = ["subnet-0b836507495991415", "subnet-0cb479c06a51a041d"]

      instance_types = var.instance_types
      ami_type = var.ami_type
      capacity_type  = "ON_DEMAND"
      attach_cluster_primary_security_group = true

    }
  }

  # aws-auth configmap
  # manage_aws_auth_configmap = true
  # aws_auth_users            = var.users
}