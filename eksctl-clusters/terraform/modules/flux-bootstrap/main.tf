locals {
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Flux
data "flux_install" "main" {
  target_path = var.target_path
  version     = var.flux_version
}

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.repository_name}"
  branch      = var.branch
}

# Kubectl
resource "kubectl_manifest" "flux_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: flux-system
  YAML
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each  = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value

  depends_on = [kubectl_manifest.flux_namespace]
}

resource "kubectl_manifest" "sync" {
  for_each  = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value

  depends_on = [
    kubectl_manifest.flux_namespace,
    kubectl_manifest.install
  ]
}

resource "kubectl_manifest" "flux_sync_secret" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${data.flux_sync.main.secret}
      namespace: ${data.flux_sync.main.namespace}
    type: Opaque
    data:
      identity: ${base64encode(tls_private_key.main.private_key_pem)}
      identity.pub: ${base64encode(tls_private_key.main.public_key_pem)}
      known_hosts: ${base64encode(local.known_hosts)}
  YAML

  depends_on = [kubectl_manifest.install]
}

# GitHub
data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

locals {
  github_repository = data.github_repository.main
  patched_kustomize_content = format("%s\n", trimspace(
    <<-EOF
    ${trimspace(data.flux_sync.main.kustomize_content)}
    ${trimspace(var.kustomization_patches)}
    EOF
  ))
}

resource "github_repository_deploy_key" "main" {
  repository = data.github_repository.main.name
  title      = var.cluster_name
  key        = tls_private_key.main.public_key_openssh
  read_only  = var.gihub_key_read_only
}

resource "github_repository_file" "install" {
  repository = data.github_repository.main.name
  branch     = var.branch
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
}

resource "github_repository_file" "sync" {
  repository = data.github_repository.main.name
  branch     = var.branch
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
}

resource "github_repository_file" "kustomize" {
  repository = data.github_repository.main.name
  branch     = var.branch
  file       = data.flux_sync.main.kustomize_path
  content    = local.patched_kustomize_content
}
