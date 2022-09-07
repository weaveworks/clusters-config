#
# Set up & config
#
terraform {
  required_version = ">=1.2"

  backend "local" {}

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

locals {
  base_name = "clusters-config"
}

#
# Actual resources
#
resource "aws_s3_bucket" "state_bucket" {
  bucket = "${local.base_name}-terraform-state"
}

resource "aws_s3_bucket_acl" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "lock_table" {
  name           = "${local.base_name}-lock-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
