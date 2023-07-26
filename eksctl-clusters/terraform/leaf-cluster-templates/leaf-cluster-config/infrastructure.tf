#
# create flux kustomization to deploy infrastructure
#

resource "github_repository_file" "infrastructure" {
  # repository    = data.github_repository.this.name
  repository     = module.flux_bootstrap.repository_name
  branch         = var.branch
  file           = "${local.flux_target_path}/infrastructure.yaml"
  commit_email   = var.git_commit_email
  commit_author  = var.git_commit_author
  commit_message = "${local.flux_target_path}/infrastructure.yaml"
  content = templatefile("${path.module}/templates/kustomization.tftpl", {
    name       = "infrastructure"
    namespace  = "flux-system"
    path       = "clusters/infrastructure"
    wait       = true
    depends_on = []
  })
}
