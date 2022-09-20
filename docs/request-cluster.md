## Request a cluster:
1. Clone the repo
1. Run the following command to generate the cluster directory:
    ```bash
      ./eksctl-clusters/scripts/request-cluster.sh --cluster-name <CLUSTER_NAME> 
    ```
1. For more options, run
    ```bash
      ./eksctl-clusters/scripts/request-cluster.sh -h/--help 
    ```

### The script will do the following:
1. Check if the cluster is created before.
1. Create a branch for the cluster, the branch is prefixed with "cluster-".
1. Create the cluster directory `eksctl-clusters/cluaters/CLUSTER_NAME`.
1. Copy eksctl cluster-config-file with default values to `eksctl-clusters/cluaters/CLUSTER_NAME/eksctl-cluster.yaml`. 
1. Copy cluster configuration files "**core** or **enterprise** to `eksctl-clusters/clusters/CLUSTER_NAME/management`.
