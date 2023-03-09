variable "region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "the EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.24"
}

variable "instance_types" {
  default= "t3.medium"
}

variable "ami_type" {
  description = "Nodes AMI type"
}
