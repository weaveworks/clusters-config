provider "aws" {
  region = var.region

  default_tags {
    tags = merge({
      source  = "Terraform Managed"
      cluster = var.cluster_name
    }, var.tags)
  }
}

provider "github" {
  # use`GITHUB_TOKEN`
  owner = var.github_owner
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# data "terraform_remote_state" "eks_core" {
#   backend = "s3"

#   config = {
#     bucket = var.eks_core_state_bucket
#     key    = var.eks_core_state_key
#     region = var.region
#   }
# }

data "github_repository" "this" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

module "flux_bootstrap" {
  source                  = "../../modules/flux-bootstrap"
  aws_region              = var.region
  cluster_name            = var.cluster_name
  github_owner            = var.github_owner
  repository_name         = var.repository_name
  branch                  = "main"
  target_path             = local.flux_target_path
  commit_author           = var.git_commit_author
  commit_email            = var.git_commit_email
  use_existing_repository = true
}

# data "aws_caller_identity" "current" {}

# resource "kubectl_manifest" "aws_auth" {
#   yaml_body = <<-YAML
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-auth
#   namespace: kube-system
# data:
#   mapAccounts: |
#     - "${data.aws_caller_identity.current.account_id}"
#   mapRoles: |
#     - groups:
#         - system:masters
#       rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AdministratorAccess
#       username: admin
#     - groups:
#       - system:bootstrappers
#       - system:nodes
#       rolearn: ${module.system_node_group.node_group_role.arn}
#       username: system:node:{{EC2PrivateDNSName}}
#     - groups:
#       - system:bootstrappers
#       - system:nodes
#       rolearn: ${module.worker_node_group.node_group_role.arn}
#       username: system:node:{{EC2PrivateDNSName}}
#   mapUsers: |
#     %{~if length(local.cluster_admin_users) > 0~}
#     %{~for user in local.cluster_admin_users~}
#     - groups:
#         - system:masters
#       userarn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}
#       username: ${user}
#     %{~endfor~}
#   %{~else~}
#     []
#   %{~endif~}
# YAML
# }

# #
# # cleanup 'LoadBalancer' services that would prevent the cluster from being destroyed
# #
# resource "null_resource" "svc_cleanup" {
#   triggers = {
#     cluster = var.cluster_name
#     region  = var.region
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<-EOF
#       aws eks update-kubeconfig --region ${self.triggers.region} --name ${self.triggers.cluster} --kubeconfig ./kubeconfig
#       for svc in $(kubectl get svc -A -o json --kubeconfig ./kubeconfig | jq -cr '.items[] | select(.spec.type=="LoadBalancer") | {name: .metadata.name, namespace: .metadata.namespace}'); do
#         _jq() {
#           echo $svc | jq -r $1
#         }
#         kubectl -n $(_jq '.namespace') delete svc $(_jq '.name') --kubeconfig ./kubeconfig --timeout=5m
#       done
#       for ingress in $(kubectl get ingress -A -o json --kubeconfig ./kubeconfig | jq -cr '.items[] | {name: .metadata.name, namespace: .metadata.namespace}'); do
#         _jq() {
#           echo $ingress | jq -r $1
#         }
#         kubectl -n $(_jq '.namespace') delete ingress $(_jq '.name') --kubeconfig ./kubeconfig --timeout=5m
#       done
#     EOF
#   }

#   depends_on = [kubectl_manifest.aws_auth]
# }

# #
# # route53 routing
# #
# data "aws_route53_zone" "main" {
#   name = var.route53_main_domain
# }

# resource "aws_route53_zone" "sub" {
#   name          = "${var.cluster_name}.${var.route53_main_domain}"
#   force_destroy = true
# }

# resource "aws_route53_record" "sub_ns" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = aws_route53_zone.sub.name
#   type    = "NS"
#   ttl     = "30"
#   records = aws_route53_zone.sub.name_servers
# }

# resource "aws_autoscaling_schedule" "set-scale-to-zero-ng-worker" {
#   scheduled_action_name  = "scale"
#   min_size               = var.shrink ? 0 : var.min_size
#   max_size               = var.shrink ? 0 : var.max_size
#   desired_capacity       = var.shrink ? 0 : var.desired_size
#   recurrence             = "*/5 * * * *"
#   autoscaling_group_name = module.worker_node_group.node_group.resources[0].autoscaling_groups[0].name
# }
