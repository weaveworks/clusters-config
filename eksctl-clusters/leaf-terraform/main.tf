module "tf-controller" {
  source = "./modules/tf-controller"
}

module "sync-secrets" {
  source = "./modules/sync-secrets"
}

module "flux" {
  source = "./modules/flux"
}

module "external-secrets" {
  source = "./modules/external-secrets"
}

