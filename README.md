# clusters-config
Configuration for engineering's ephemeral clusters

## Repo Layout:
- [terraform](./terraform/) contains terraform for provisioning resources in the Engineering Sandbox AWS Account.
- [eksctl-clusters](./eksctl-clusters/) contians scripts, templates, flux configuration, and clusters created by eksctl.

## Getting Started
### Required dependencies
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [direnv](https://direnv.net/)
- [eksctl](https://eksctl.io/introduction/#installation)
- [gsts](https://github.com/ruimarinho/gsts)
- [pre-commit](https://pre-commit.com/)

### Recommended dependencies
- An [EditorConfig](https://editorconfig.org/) compatible editor.

### Getting access to Engineering Sandbox AWS Account

- File an issue on [corp](https://github.com/weaveworks/corp) to request access to Engineering Sandbox AWS Account to assume `WeaveEksEditor` role **(include your email in the issue)**.

- Authenticate in your CLI with `WeaveEksEditor` role:
    ```bash
    $ export GOOGLE_USERNAME=<YOUR_EMAIL>
    $ source env.sh
    ✔ Login successful!
    Environment configured, authenticated to AWS as arn:aws:iam::894516026745:role/WeaveEksEditor.
    ```

### How do we manage clusters?
- Each cluster/environment has its own branch.
- Clusters are provisioned by creating a new `cluster-<CLUSTER_NAME>` branch and destroyed by deleting the branch.
- Clusters branches and directories are created automatically after a user [request a cluster](./docs/cluster.md#requesting-a-cluster). All values are set and user shouldn't need to add anything (unless he wants to customize his environment). The user can review the files before pushing the new branch in order to provision his cluster
- The cluster directory `./eksctl-clusters/clusters/<CLUSTER_NAME>` contains:
    - Eksctl cluster configurations.
    - flux, gitops, other apps files.

### Slack notifications:
We send slack notifications to #clusters-config channel. We notify for:
1. Create a cluster
1. Delete a cluster
1. TTL is about to end.

### Requesting a new cluster
To request a new cluster, follow the [requesting a new cluster](./docs/cluster.md#requesting-a-cluster) doc

### Pre-Commit hooks

This repository uses [pre-commit hooks](https://pre-commit.com/) to run quick
checks against it. Please install before use.
