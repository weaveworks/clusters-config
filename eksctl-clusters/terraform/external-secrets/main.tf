resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  chart      = "./charts/external-secrets"
}