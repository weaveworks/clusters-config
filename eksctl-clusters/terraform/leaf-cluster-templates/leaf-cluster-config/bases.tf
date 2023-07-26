#
# create flux kustomization to deploy bases
#
resource "github_repository_file" "kubeconfig" {
  count = var.include_bases == true ? 1 : 0

  repository    = module.flux_bootstrap.repository_name
  branch        = var.branch
  file          = "${local.flux_target_path}/bases.yaml"
  commit_email  = var.git_commit_email
  commit_author = var.git_commit_author
  commit_message = "${local.flux_target_path}/bases.yaml"
  content = templatefile("${path.module}/templates/kustomization.tftpl", {
    name       = "bases"
    namespace  = "flux-system"
    path       = var.bases_path
    wait       = false
    depends_on = []
  })
}
