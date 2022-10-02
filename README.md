# clusters-config
Configuration for engineering's ephemeral clusters

## Repo Layout:
- [terraform](./terraform/) contains terraform for provisioning resources in the Engineering Sandbox AWS Account.
- [eksctl-clusters](./eksctl-clusters/) contians scripts, templates, flux configuration, and clusters created by eksctl.

## Getting Started
### Getting access to Engineering Sandbox AWS Account

- Follow [Accessing AWS Resources](https://www.notion.so/weaveworks/Accessing-AWS-Resources-600faa584fec4c6ba5b0f2ef27be309e) to get access to the Engineering Sandbox AWS Account from the cli
- Assume `WeaveEksEditor` role using:
    ```bash
    aws sts assume-role --role-arn "arn:aws:iam::894516026745:role/WeaveEksEditor" --role-session-name <SESSION_NAME>

    ```

### How do we manage clusters?
- Each cluster/environment has its own branch.
- Clusters are provisioned by creating a new `cluster-<CLUSTER_NAME>` branch and destroyed by deleting the branch.
- Clusters branches and directories are created automatically after a user [request a cluster](./docs/request-cluster.md). All values are set and user shouldn't need to add anything (unless he wants to customize his environment). The user can review the files before pushing the new branch in order to provision his cluster
- The cluster directory `./eksctl-clusters/<CLUSTER_NAME>` contains:
    - Eksctl cluster configurations.
    - flux, gitops, other apps files.

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
