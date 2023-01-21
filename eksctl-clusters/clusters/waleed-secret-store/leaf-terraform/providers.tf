terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.33"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 15.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.11"
    }
  }
}
