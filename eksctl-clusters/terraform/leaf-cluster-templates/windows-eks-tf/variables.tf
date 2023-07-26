variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "the EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.26"
}

variable "instance_types" {
  default = "m5.xlarge"
}

variable "ami_type" {
  description = "Nodes AMI type"
  default     = "WINDOWS_CORE_2022_x86_64"
}

variable "linux_ami_type" {
  description = "Linux Node AMI type"
  default     = "AL2_x86_64"
}

variable "roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = null
}

variable "owner" {
  type        = string
  description = "repo owner"
  default     = "caseware"
}

variable "branch" {
  type        = string
  description = "branch name"
  default     = "main"
}

variable "git_commit_author" {
  type        = string
  description = "Git commit author (defaults to author value from auth)"
  default     = null
}

variable "git_commit_email" {
  type        = string
  description = "Git commit email (defaults to email value from auth)"
  default     = null
}

variable "git_commit_message" {
  type        = string
  description = "Set custom commit message"
  default     = null
}
