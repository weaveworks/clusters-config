variable "region" {
  type        = string
  description = "AWS region for cluster"
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "tags" {
  type        = map(string)
  description = "resource specific tags"
  default     = null
}

# variable "customer" {
#   type        = string
#   description = "owning customer of aws resources"
#   default     = "caseware"
# }

variable "github_owner" {
  type        = string
  description = "github owner"
  default     = "caseware"
}

variable "repository_name" {
  type        = string
  description = "github repository name"
  default     = "eks-wge-management-cwcloudtest"
}

# variable "repository_visibility" {
#   type        = string
#   description = "How visible is the github repo"
#   default     = "private"
# }

variable "branch" {
  type        = string
  description = "branch name"
  default     = "main"
}

variable "target_path" {
  type        = string
  description = "flux sync target path"
}

variable "flux_sync_directory" {
  type        = string
  description = "directory within target_path to sync flux"
  default     = "flux"
}

# variable "route53_main_domain" {
#   type        = string
#   description = "main domain address (leaf domain will be built using <cluster_name>.<route53_main_domain> format)"
# }

# variable "desired_size" {
#   type        = number
#   description = "Desired number of instances in Node Group"
#   default     = 2
# }

# variable "max_size" {
#   type        = number
#   description = "Max number of instances in Node Group"
#   default     = 3
# }

# variable "min_size" {
#   type        = number
#   description = "Min number of instances in Node Group"
#   default     = 1
# }

# variable "shrink" {
#   type        = bool
#   description = "Shrink worker node group"
#   default     = false
# }

# variable "capacity_type" {
#   type        = string
#   description = "Capacity associated with Node Group (SPOT or ON_DEMAND)"
#   default     = null
# }

# variable "instance_type" {
#   type        = string
#   description = "Instance type associated with Node Group"
#   default     = "t3.medium"
# }

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

variable "include_bases" {
  type        = bool
  description = "create bases kustomization"
  default     = true
}

variable "bases_path" {
  type        = string
  description = "git repo path to bases files"
  default     = "clusters/bases"
}

# variable "eks_core_state_bucket" {
#   type        = string
#   description = "s3 bucket that contains eks core module outputs"
# }

# variable "eks_core_state_key" {
#   type        = string
#   description = "key for s3 bucket that contains eks core module outputs"
# }

# variable "cluster_admin_users" {
#   type        = list(string)
#   description = "list of IAM users to be granted admin access in eks aws_auth configmap"
#   default     = []
# }

# variable "cluster_admin_users_string" {
#   type        = string
#   description = "comma seperated string of IAM users to be granted admin access in eks aws_auth configmap"
#   default     = ""
# }
