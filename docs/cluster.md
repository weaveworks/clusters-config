## Requesting a cluster:
1. Clone the repo
    ```bash
    git clone git@github.com:weaveworks/clusters-config.git
    ```
1. Run the `request-cluster` script
    ```bash
    make request-cluster ARGS="--team <TEAM_NAME> --cluster-name <CLUSTER_NAME> --weave-mode <WEAVE_MODE> --delete-after 10"
    ```
    > **_Note:_** We recommend using `make` instead of using the script path.

    For more options see this [section](#request-cluster-options), or run
      ```bash
      make request-cluster ARGS="--help"
      ```
1. Add and commit your cluster directory then push the new branch

1. Wait until the cluster is provisioned. It might take around 20~30 minutes. You can check your provisioning job in the [actions](https://github.com/weaveworks/clusters-config/actions) tab.

1. Join **#clusters-config** slack channel to get notified once the cluster is provisioned!

## Get kubeconfig file:

  > **_NOTE:_** You have to wait until the cluster is provisioned before you get the kubeconfig file, otherwise you may get an error like this: `Error: cannot perform Kubernetes API operations on cluster <CLUSTER_NAME> in "eu-north-1" region due to status "CREATING"`

  ```bash
  eksctl utils write-kubeconfig --region eu-north-1 --cluster <CLUSTER_NAME> --kubeconfig=$HOME/.kube/config
  ```

## Deploy Specific Version of WGE:
By default, flux will deploy the latest version of WGE and will reconcile new versions once released. To deploy specific release, use the `--weave-version` option.

```bash
make request-cluster ARGS="--cluster-name <CLUSTER_NAME> --weave-mode enterprise --weave-version <WEAVE_VERSION> --team <TEAM_NAME>"
```

## Develop and test your feature branch of WGE!
You can deploy **WGE** from a feature branch and renconcile changes automatically. Use `--weave-branch` option while you are requesting the cluster.

```bash
make request-cluster ARGS="--cluster-name <CLUSTER_NAME> --weave-mode enterprise --weave-branch <BRANCH_NAME> --team <TEAM_NAME>"
```

## Develop and test your feature branch of gitops OSS!
You can deploy **gitops OSS** from a feature branch and renconcile changes automatically. Use `--oss-tag` option while you are requesting the cluster.

```bash
make request-cluster ARGS="--cluster-name <CLUSTER_NAME> --weave-mode core --oss-tag <BRANCH_NAME> --team <TEAM_NAME>"
```

> **_Note:_** There is no automatic build for gitops OSS feature branches. You should buid the image on you local labtop, tag the image, then push it to `weaveworks/gitops-oss-prs` dockerhub repository.


## Accessing UI:

Every provisioned cluster has a domain registered along with it and this domain points to the UI service. You can access the UI by accessing the domain: <cluster_name>.eng-sandbox.weave.works

### Access the UI using one of the following users::
1. Basic auth:
    ```bash
    username = wego-admin
    password = password
    ```
    User have admin permission to all namespaces.

1. Dex OIDC users:
  The following static users are created by default:

    | User                    | password | Permission                             | gitops Rpac | enterprise Rbac |
    |--                       |--        |--                                      |--           |--               |
    | admin@test.invalid      | password | full access to all resources           | wego-admin | [wego-admin](https://docs.gitops.weave.works/docs/cluster-management/getting-started/#add-common-rbac-to-the-repo) + [gitops-reader](https://github.com/weaveworks/weave-gitops-enterprise/blob/97c08e97abaafd8fd5a3781fa0c07ddf3607fce7/charts/mccp/templates/rbac/user_roles.yaml#L4-L14) |
    | admin-apps@test.invalid | password | full access to **apps** namespace only | wego-admin | wego-admin + gitops-reader "apps namespace only" |
    | ro@test.invalid         | password | read-only access to all namespaces     | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) |
    | ro-apps@test.invalid    | password | read-only access to **apps** namespace | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) "apps namespace only" | [wego-readonly-role](../eksctl-clusters/apps/common/dex/readonly-cluster-role.yaml) "apps namespace only" |

## Pipeline Controller UI:
By default, we will expose a URL for the pipeline controller. You can access it by using the following domain: promotions-<cluster_name>.eng-sandbox.weave.works

## Cluster TTL (time to live):
Every cluster created by the `request-cluster` script runs for 7 days by default, then it will be auto deleted. To define the TTL in days, use `--delete-after` option while requesting the cluster. If you already provisioned your cluster, you can [extend TTL](#extending-your-cluster-ttl).

Join #clusters-config slack channel to get notifications before ttl ends!

### Extending your cluster TTL:

You can extend your cluster TTL by running:
```bash
  make extend-ttl ARGS="--cluster-name <CLUSTER_NAME> --extend <NUMBER_OF_DAYS_TO_EXTEND>"
```

## Request cluster options:

| <nobr>Option</nobr>              | Default | Required | Description |
|----------------------------------|---------|----------|-------------|
| <nobr>`--cluster-name`</nobr>    |         | Yes      | Cluster's Name. It should be unique |
| <nobr>`--cluster-version`</nobr> | 1.23    | No       | Kubernetes cluster version |
| <nobr>`--weave-mode`</nobr>      | core    | No       | Select between installing WGE, WG-Core, leaf-cluster or not install any (enterprise|core|leaf|none)". Leaf option is to create a cluster that will be used as leaf cluster. You still need to join that cluster to yor management cluster. |
| <nobr>`----oss-tag`</nobr>       |         | No       | Select a specific tag of OSS (works only with --weave-mode=core) |
| <nobr>`--weave-version`</nobr>   |         | No       | Select a specific released version (works only with --weave-mode=enterprise) |
| <nobr>`--weave-branch`</nobr>    |         | No       | Select a specific git branch for installation (works only with --weave-mode=enterprise). Note: You can't use both `--weave-branch` and `--weave-version`|
| <nobr>`--enable-flagger`</nobr>  | false   | No       | Flagger will be installed on the cluster (only available when --weave-mode=enterprise|leaf) |
| <nobr>`--enable-policies`</nobr> | false   | No       | Default policies will be installed on the cluster (only available when --weave-mode=enterprise|leaf) |
| <nobr>`--delete-after`</nobr>    | 7       | No       | Cluster will be auto deleted after this number of days |
| <nobr>`--team`</nobr>            |         | Yes      | Engineering team name |

## What does request-cluster script do?

1. Check if the cluster is created before.
1. Create a branch for the cluster, the branch is prefixed with "cluster-". If the branch was created before, it will fail.
1. Create the cluster directory `eksctl-clusters/clusters/<CLUSTER_NAME>`.
1. Copy eksctl cluster-config-file with default values to `eksctl-clusters/clusters/<CLUSTER_NAME>/eksctl-cluster.yaml`.
1. Copy cluster kustomization files to `eksctl-clusters/clusters/<CLUSTER_NAME>`.
