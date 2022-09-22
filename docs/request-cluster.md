## Requesting a cluster:
1. Clone the repo
    ```bash
      git clone git@github.com:weaveworks/clusters-config.git
    ```
1. Run the `request-cluster` script
    ```bash
      ./eksctl-clusters/scripts/request-cluster.sh --cluster-name <CLUSTER_NAME> --weave-mode core|enterprise|none
    ```
    For more options, run
      ```bash
        ./eksctl-clusters/scripts/request-cluster.sh --help
      ```
      #### What does the script do?
      1. Check if the cluster is created before.
      1. Create a branch for the cluster, the branch is prefixed with "cluster-".
      1. Create the cluster directory `eksctl-clusters/clusters/<CLUSTER_NAME>`.
      1. Copy eksctl cluster-config-file with default values to `eksctl-clusters/cluaters/<CLUSTER_NAME>/eksctl-cluster.yaml`.
      1. Copy cluster configuration files "**core** or **enterprise** to `eksctl-clusters/clusters/<CLUSTER_NAME>/management`.

1. Add and commit your cluster directory then push the new branch

1. Get kubeconfig file:
    ```bash
    eksctl utils write-kubeconfig --region eu-north-1 --cluster $CLUSTER_NAME --kubeconfig=$HOME/.kube/config
    ```

## Accessing UI:
In order to access the UI, you need to port-farword `clusters-service` in case you deployed WGE app, or `weave-gitops` service for gitops app.

### Authenticate using dex:
  1. Add dex to your `/etc/hosts`.
      ```bash
      127.0.0.1 dex-dex.dex.svc.cluster.local
      ```
  1. Port-farword dex service:
      ```bash
      kubectl port-forward -n dex svc/dex-dex 5556:5556
      ```

### Access the UI using one of the following users:
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
