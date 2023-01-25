data "kubernetes_secret_v1" "secret-to-sync-remote" {
  metadata {
    name      = "ssh-creds"
    namespace = "source-remote"
  }
  provider = kubernetes.this
}

resource "kubernetes_secret_v1" "target-to-sync-remote" {
  metadata {
    name      = data.kubernetes_secret_v1.secret-to-sync-remote.metadata[0].name
    namespace = data.kubernetes_secret_v1.secret-to-sync-remote.metadata[0].namespace
  }

  data     = data.kubernetes_secret_v1.secret-to-sync-remote.data
  provider = kubernetes.leaf
}
