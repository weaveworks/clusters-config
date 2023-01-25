terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.33"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14"
    }
  }
}