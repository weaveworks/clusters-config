provider "aws" {
  region = "eu-north-1"
}

data "aws_eks_cluster" "this" {
  name = "waleed-tf"
}

data "aws_eks_cluster_auth" "this" {
  name = "waleed-tf"
}

data "aws_eks_cluster" "leaf" {
  name = "default_leaf-control-plane"
}

data "aws_eks_cluster_auth" "leaf" {
  name = "default_leaf-control-plane"
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
  alias                  = "this"
}


provider "kubectl" {
  host                   = data.aws_eks_cluster.leaf.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.leaf.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.leaf.token
  load_config_file       = false
  alias                  = "leaf"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  alias                  = "this"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.leaf.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.leaf.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.leaf.token
  alias                  = "leaf"
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

module "sync-secrets" {
  source = "./modules/sync-secrets"
  providers = {
    aws             = aws
    kubectl         = kubectl
    kubernetes.this = kubernetes.this
    kubernetes.leaf = kubernetes.leaf
  }
}

module "flux" {
  source     = "./modules/flux"
  depends_on = [module.sync-secrets]
  providers = {
    kubectl = kubectl
    flux    = flux
    tls     = tls
  }
}

module "external-secrets" {
  source     = "./modules/external-secrets"
  depends_on = [module.flux]
}
