# leaf-kubeconfig

WE are using this module to create kubeconfig-file for leaf-clusters and push it to the github repo that we use so flux reconsile it to the management cluster. This way, management cluster has access to leaf-cluster.

The kubeconfig file should be managed using one of the secret management solution like SOPs or AWS secret manager. We will handle it very soon.
