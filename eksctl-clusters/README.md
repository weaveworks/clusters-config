# eksctl-clusters


## Request a cluster:
1. Clone the repo
1. Run the following command to generate the cluster directory:
    ```bash
      ./scripts/request-cluster.sh CLUSTER_NAME
    ```
    - The script will create the cluster directory under clusters directory.
    - The eksctl cluster-config-file with default values will be created at `cluaters/CLUSTER_NAME/eksctl-cluster.yaml`, and default management cluster configuration files at `clusters/CLUSTER_NAME/management`.

## Cluster config file:
- All values are set and you shouldn't change any.

## Structure:
- `Clusters` where we save all data related to a created cluster. **Flux** will be connected to this repo and add its files to the **clusters/CLUSTER_NAME** dir.
- `wge-templates` where we save all possible WGE templates like "profiles, clusters, policies ..etc". We copy them by default to all created clusters and let flux reconcile them.
- `eks-cluster-tmp.yaml` is the eks cluster template that will be use in creating the eks cluster. It will be copied under each cluster dir.
- `scripts` where all of our scripts will live.
