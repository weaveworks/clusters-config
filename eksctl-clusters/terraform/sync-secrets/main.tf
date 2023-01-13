provider "kubectl" {
}

provider "kubernetes" {
}


resource "kubectl_manifest" "source_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: source
  YAML
}


resource "kubectl_manifest" "target_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: target
  YAML
}


data "kubectl_filename_list" "manifests" {
  pattern = "./secrets/*.yaml"
}

resource "kubectl_manifest" "secrets" {
  count     = length(data.kubectl_filename_list.manifests.matches)
  yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
}


resource "null_resource" "sync_secret" {
  depends_on = [kubectl_manifest.source_namespace, kubectl_manifest.target_namespace,kubectl_manifest.secrets]
  provisioner "local-exec" {
    command = <<-EOF
      kubectl get secret -n source -l sync="enabled" -o yaml | sed 's/namespace: .*/namespace: target/' | kubectl apply -f -
    EOF
  }
}