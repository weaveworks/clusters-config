provider "aws" {
  region = "eu-north-1"

}
data "aws_eks_cluster" "this" {
  name = "wge2205"
}

data "aws_eks_cluster_auth" "this" {
  name = "wge2205"
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}



resource "kubectl_manifest" "external_secrets_repo" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta1
    kind: HelmRepository
    metadata:
      name: external-secrets
      namespace: flux-system
    spec:
      interval: 10m
      url: https://charts.external-secrets.io
  YAML
}

resource "kubectl_manifest" "external_secrets_release" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: external-secrets
      namespace: flux-system
    spec:
      releaseName: external-secrets
      targetNamespace: external-secrets
      interval: 10m
      chart:
        spec:
          chart: external-secrets
          sourceRef:
            kind: HelmRepository
            name: external-secrets
            namespace: flux-system
      values:
        installCRDs: true
      install:
        createNamespace: true
  YAML
}