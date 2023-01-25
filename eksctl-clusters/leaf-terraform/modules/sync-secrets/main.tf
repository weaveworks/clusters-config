provider "aws" {
  region = "eu-north-1"

}
data "aws_eks_cluster" "this" {
  name = "waleed-tf"
}

data "aws_eks_cluster_auth" "this" {
  name = "waleed-tf"
}

data "local_file" "token" {
  filename = "/var/run/secrets/kubernetes.io/serviceaccount/token"
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}


resource "kubectl_manifest" "source_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: source-remote
  YAML
}


resource "kubectl_manifest" "target_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: target-remote
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
      kubectl get secret -n source-remote -l sync="enabled" -o yaml | sed 's/namespace: .*/namespace: target-remote/' | kubectl apply -f -
    EOF
  }
}