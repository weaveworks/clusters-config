# Terraform modules for leaf cluster

- Sync Secrets: is used to sync secrets to leaf cluster
- Flux: bootstrap flux into leaf cluster
- External Secrets: installs the operator in the leaf cluster


## Blockers and manual work

- needs to apply flux namespace first [more info here](https://github.com/weaveworks/clusters-config/blob/cluster-wge-2205/eksctl-clusters/terraform/flux/README.md)
- tf-controller needs service account to work in case of aws or gke currently implemented using aws provider if otherwise needs to change the provider configurations
- flux bootstrapping into clusters config repo leaf cluster requires admin privillages, possible fix when [this](https://github.com/weaveworks/clusters-config/issues/322) done, stacktrace as the following

  ```bash
  │ Error: POST https://api.github.com/repos/weaveworks/clusters-config/keys: 404 Not Found []
  │ 
  │   with github_repository_deploy_key.main,
  │   on main.tf line 126, in resource "github_repository_deploy_key" "main":
  │  126: resource "github_repository_deploy_key" "main" {
  │ 
  ```
- needs to create the namespace secrets on the leaf cluster before applying
