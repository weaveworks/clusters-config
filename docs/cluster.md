## Requesting a cluster:
1. Clone the repo
    ```bash
      git clone git@github.com:weaveworks/clusters-config.git
    ```
1. Run the `request-cluster` script
    ```bash
      ./eksctl-clusters/scripts/request-cluster.sh --cluster-name <CLUSTER_NAME> --weave-mode core|enterprise|none --delete-after 15
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
      1. Copy cluster kustomization files **core** or **enterprise** to `eksctl-clusters/clusters/<CLUSTER_NAME>`.

1. Add and commit your cluster directory then push the new branch

1. Wait until the cluster is provisioned. It might take around 20 minutes. You can check your provisioning job in the [actions](https://github.com/weaveworks/clusters-config/actions) tab.

1. Get kubeconfig file:

    **Note:** You have to wait until the cluster is provisioned before you get the kubeconfig file, otherwise you may get an error like: `Error: cannot perform Kubernetes API operations on cluster <CLUSTER_NAME> in "eu-north-1" region due to status "CREATING"`
    ```bash
    eksctl utils write-kubeconfig --region eu-north-1 --cluster $CLUSTER_NAME --kubeconfig=$HOME/.kube/config
    ```

## Deploy Specific Version of WGE:
By default, flux will deploy the latest version of WGE and will reconcile new versions once released. To deploy specific release, use the `--weave-version` option.

```bash
./eksctl-clusters/scripts/request-cluster.sh --cluster-name <CLUSTER_NAME> --weave-mode enterprise --weave-version <WEAVE_VERSION>
```

## Develop and test your code!
You can deploy WGE from a feature branch and renconcile changes automatically. Use `--weave-branch` option while you are requesting the cluster.

```bash
./eksctl-clusters/scripts/request-cluster.sh --cluster-name <CLUSTER_NAME> --weave-mode enterprise --weave-branch <BRANCH_NAME>
```

## Accessing UI:
In order to access the UI, you need to port-farword `clusters-service` in case you deployed WGE app, or `weave-gitops` service for gitops app:
```bash
# WGE
kubectl port-forward -n flux-system svc/clusters-service 9001:8000

# Weave Gitops Core
kubectl port-forward -n flux-system svc/ww-gitops-weave-gitops 9001:9001
```
You can then access the UI on `localhost:9001`

**WARNING: Please don't change port 9001 because this is the port used by dex for authentication.**

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

    | User                    | password | Permission                             | gitops Rpac | enterprise Rbac |
    |--                       |--        |--                                      |--           |--               |
    | admin@test.invalid      | password | full access to all resources           | wego-admin | [wego-admin](https://docs.gitops.weave.works/docs/cluster-management/getting-started/#add-common-rbac-to-the-repo) + [gitops-reader](https://github.com/weaveworks/weave-gitops-enterprise/blob/97c08e97abaafd8fd5a3781fa0c07ddf3607fce7/charts/mccp/templates/rbac/user_roles.yaml#L4-L14) |
    | admin-apps@test.invalid | password | full access to **apps** namespace only | wego-admin | wego-admin + gitops-reader "apps namespace only" |
    | ro@test.invalid         | password | read-only access to all namespaces     | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) |
    | ro-apps@test.invalid    | password | read-only access to **apps** namespace | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) "apps namespace only" | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) "apps namespace only" |

## Cluster TTL (time to live):
Every cluster created by the `request-cluster` script runs for 7 days by default, then it will be auto deleted. To define the TTL in days, use `--delete-after` option while requesting the cluster. If you already provisioned your cluster, you can [extend TTL](#extending-your-cluster-ttl).

### Extending your cluster TTL:

You can extend your cluster TTL by running:
```bash
  ./eksctl-clusters/scripts/extend-cluster-ttl.sh --cluster-name <CLUSTER_NAME> --extend <NUMBER_OF_DAYS_TO_EXTEND>
```
