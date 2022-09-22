# eksctl-clusters

This directory contians scripts, templates, flux configuration, and clusters created by eksctl.

## Request a cluster:
1. Clone the repo
1. Run the following command to generate the cluster directory:
    ```bash
      ./eksctl-clusters/scripts/request-cluster.sh --cluster-name <CLUSTER_NAME> 
    ```

### Notes on requesting a cluster:
- 

## How do we manage clusters?
1. Each cluster/envirinment has its own branch.
1. The cluster directory contains: 
    - eksctl cluster configurations.
    - management directory, where all flux, gitops, other apps files will live.
1. Clusters branch and directory will be created automatically after a user request a cluster.

## Cluster config file:
- All values are set and you shouldn't change any.
- You can review the cluster's configuration before you push changes to the cluster branch. `./clusters/${CLUSTER_NAME}/eksctl-cluster.yaml`

## Structure:
- [apps](./apps/) where we keep apps config files.
    - `core`
        - Where we save several apps to be installed by default on all clusters, like, dex and podinfo.
    - `enterprise`
        - Containes WGE template yaml files to be reconsiled by fluxcd if you used `--weave-mode enterprise` option.
    - `gitops`
        - Containes gitops app yaml files. They will be installed if you used `--weave-mode core` option.
- [Clusters](./clusters/) where we save all data related to a created cluster. **Flux** will be connected to this repo and add its files to the **eksctl-clusters/clusters/CLUSTER_NAME** dir.
- [eks-cluster-tmp.yaml](./eks-cluster-tmp.yaml) is the eks cluster template that will be use in creating the eks cluster. It will be copied under each cluster dir.
- [scripts](./scripts/) where all of our scripts will live.
- [shared-secrets](./shared-secrets/) Where we save secrets that are shared for all clusters. like, entitlement-secret.yaml
- [flux-kustomization-tmp.yaml](./flux-kustomization-tmp.yaml) is the flux kustomization template that is used to patch flux controllers on bootstrapping. It will be copied under each cluster dir.
- [secrets-kustomization-tmp.yaml](./secrets-kustomization-tmp.yaml) is the shared-secrets kustomization template that references the encrypted shared-secrets dir. It will be copied under each cluster dir.

## Access UI:
In order to access the UI, you need to port-farword `clusters-service` in case you deployed WGE app, or `weave-gitops` service for gitops app.

To authenticate using dex:
  1. Add dex to your `/etc/hosts`.
      ```bash
      127.0.0.1 dex-dex.dex.svc.cluster.local
      ```
  1. Port-farword dex service:
      ```bash
      kubectl port-forward -n dex svc/dex-dex 5556:5556
      ```

Access the UI using one of the follwoing users:
1. Basic auth:
    ```bash
    username = wego-admin
    password = password
    ```
    User have admin permission to all namespaces.

1. Dex users:
The following static users are created by default:

    | User                    | password | Permission                             |
    |--                       |--        |--                                      |
    | admin@test.invalid      | password | full access to all resources           |
    | admin-apps@test.invalid | password | full access to **apps** namespace only |
    | ro@test.invalid         | password | read-only access to all namespaces     |
    | ro-apps@test.invalid    | password | read-only access to **apps** namespace |


### Get kubecofig file:
```bash
eksctl utils write-kubeconfig --region eu-north-1 -n $CLUSTER_NAME --kubeconfig=$HOME/.kube/config
```
