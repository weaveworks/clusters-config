#
# Set up & config
#
terraform {
  required_version = ">=1.2"

  backend "s3" {
    bucket = "clusters-config-terraform-state"
    key    = "clusters-config/account"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}

provider "aws" {
  region              = "eu-north-1"
  allowed_account_ids = [894516026745] # weaveworks-engineering-sandbox
}
