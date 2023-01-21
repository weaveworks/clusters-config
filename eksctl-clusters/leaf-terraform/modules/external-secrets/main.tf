provider "aws" {
  region = "eu-north-1"
}

data "aws_eks_cluster" "default_test-control-plane" {
  name = "default_test-control-plane"
}

data "aws_eks_cluster_auth" "default_test-control-plane" {
  name = "default_test-control-plane"
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.default_test-control-plane.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default_test-control-plane.certificate_authority[0].data)
  token                  = var.token
  load_config_file       = false
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
      name: external-secrets-operator
      namespace: flux-system
    spec:
      releaseName: external-secrets-operator
      targetNamespace: external-secrets-operator
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