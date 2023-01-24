module "tf-controller" {
  source = "./modules/tf-controller"
}

module "sync-secrets" {
  source = "./modules/sync-secrets"
  depends_on = [module.tf-controller]
}

module "flux" {
  source = "./modules/flux"
  depends_on = [module.sync-secrets]
}

module "external-secrets" {
  source = "./modules/external-secrets"
  depends_on = [module.flux]
}

