
variable "CLUSTER_NAME" {
  type        = string
  description = "cluster name"
  default = "test"
}

variable "github_owner" {
  type        = string
  description = "github owner"
  default = "weaveworks"
}

variable "github_token" {
  type        = string
  description = "github token"
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
  default     = "cluster-wge2205"
  description = "branch name"
}

variable "token" {
  type        = string
  description = "cluster token"
  default = "123"
}

variable "target_path" {
  type        = string
  default     = "./eksctl-clusters/clusters/wge2205-leaf"
  description = "flux sync target path"
}