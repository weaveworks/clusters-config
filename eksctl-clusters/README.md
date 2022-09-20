# eksctl-clusters

## Request a cluster:
1. Clone the repo
1. Run the following command to generate the cluster directory:
    ```bash
      ./eksctl-clusters/scripts/request-cluster.sh --cluster-name <CLUSTER_NAME> 
    ```
    The script will do the following:
      1. Check if the cluster is created before.
      1. Create a branch for the cluster, the branch is prefixed with "cluster-".
      1. Create the cluster directory `eksctl-clusters/cluaters/CLUSTER_NAME`.
      1. Copy eksctl cluster-config-file with default values to `eksctl-clusters/cluaters/CLUSTER_NAME/eksctl-cluster.yaml`. 
      1. Copy cluster configuration files "**core** or **enterprise** to `eksctl-clusters/clusters/CLUSTER_NAME/management`.

### Notes on requesting a cluster:
- 

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
