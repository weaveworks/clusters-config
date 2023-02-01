
variable "cluster_name" {
  type        = string
  description = "cluster name"
  default     = "default_leaf-control-plane"
}

variable "github_owner" {
  type        = string
  description = "github owner"
  default     = "weaveworks"
}

variable "github_token" {
  type        = string
  description = "github token"
  default     = "ssh-creds"
}

variable "repository_name" {
  type        = string
  default     = "clusters-config"
  description = "github repository name"
}

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the github repo"
}

variable "branch" {
  type        = string
  default     = "cluster-waleed-tf"
  description = "branch name"
}

variable "token" {
  type        = string
  description = "cluster token"
  default     = "leaf-kubeconfig"
}

variable "target_path" {
  type        = string
  default     = "./eksctl-clusters/clusters/waleed-tf/default/leaf"
  description = "flux sync target path"
}
