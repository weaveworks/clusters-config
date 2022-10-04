# clusters-config
Configuration for engineering's ephemeral clusters

## Repo Layout:
- [terraform](./terraform/) contains terraform for provisioning resources in the Engineering Sandbox AWS Account.
- [eksctl-clusters](./eksctl-clusters/) contians scripts, templates, flux configuration, and clusters created by eksctl.

## Getting Started
### Tools you will need to install:
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [eksctl](https://eksctl.io/introduction/#installation)
- [gsts](https://github.com/ruimarinho/gsts)
- [pre-commit](README.md#pre-commit-hooks)

### How do we manage clusters?
- Each cluster/environment has its own branch.
- Clusters are provisioned by creating a new `cluster-<CLUSTER_NAME>` branch and destroyed by deleting the branch.
- Clusters branches and directories are created automatically after a user [request a cluster](./docs/request-cluster.md). All values are set and user shouldn't need to add anything (unless he wants to customize his environment). The user can review the files before pushing the new branch in order to provision his cluster
- The cluster directory `./eksctl-clusters/clusters/<CLUSTER_NAME>` contains:
    - Eksctl cluster configurations.
    - flux, gitops, other apps files.

### Getting access to Engineering Sandbox AWS Account

- File an issue on [corp](https://github.com/weaveworks/corp) to request access to Engineering Sandbox AWS Account to assume `WeaveEksEditor` role **(include your email in the issue)**.

- Authenticate in your CLI with `WeaveEksEditor` role:
    ```bash
    export AWS_ROLE_EKS="arn:aws:iam::894516026745:role/WeaveEksEditor"
    export GOOGLE_IDP_ID=C0203uytv
    export GOOGLE_SP_ID=656726301855
    gsts --aws-role-arn "$AWS_ROLE_EKS" --sp-id "$GOOGLE_SP_ID" --idp-id "$GOOGLE_IDP_ID" --username <YOUR_EMAIL>
    ```

### Requesting a new cluster
To request a new cluster, follow the [requesting a new cluster](./docs/request-cluster.md) doc

### Pre-Commit hooks

This repository uses [pre-commit hooks](https://pre-commit.com/) to run quick
checks against it. They can be installed and run using:

```bash
$ pip3 install pre-commit
# or
$ brew install pre-commit
# Then
$ pre-commit install
# The hooks can be run with
$ pre-commit run --all
# Otherwise they'll run automatically on commit
# they can be skipped with
$ git commit -n
```
