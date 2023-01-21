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
  }
}
