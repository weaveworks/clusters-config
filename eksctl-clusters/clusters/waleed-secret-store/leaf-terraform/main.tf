module "tf-controller" {
  source = "./modules/tf-controller"
  cluster_name = var.CLUSTER_NAME
}

module "sync-secrets" {
  source = "./modules/sync-secrets"
  cluster_name = var.CLUSTER_NAME
  depends_on = [module.tf-controller]
}

module "flux" {
  source = "./modules/flux"
  cluster_name = var.CLUSTER_NAME
  depends_on = [module.sync-secrets]
}

module "external-secrets" {
  source = "./modules/external-secrets"
  cluster_name = var.CLUSTER_NAME
  depends_on = [module.flux]
}

