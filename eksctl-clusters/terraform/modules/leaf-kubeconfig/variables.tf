variable "cluster_name" {}

variable "cluster_ca_certificate" {}

variable "cluster_endpoint" {}

variable "repository_name" {
  type = string
  default = "eks-wge-management-cwcloudtest"
}

variable "github_owner" {
  type    = string
  default = "caseware"
}

variable "branch" {
  type    = string
  default = "main"
}

variable "commit_author" {
  type        = string
  description = "Git commit author (defaults to author value from auth)"
  default     = null
}

variable "commit_email" {
  type        = string
  description = "Git commit email (defaults to email value from auth)"
  default     = null
}

# variable "github_token" {
#   description = "GitHub access token used to configure the provider"
#   type        = string
# }
