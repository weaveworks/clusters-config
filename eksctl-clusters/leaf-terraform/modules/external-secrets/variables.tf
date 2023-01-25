variable "token" {
  type        = string
  description = "cluster token"
  default     = "leaf-cluster-auth"
}
variable "cluster_name" {
  type        = string
  description = "cluster name"
  default = "default_leaf-control-plane"
}