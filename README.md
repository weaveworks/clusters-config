# clusters-config
Configuration for engineering's ephemeral clusters

## Repo Layout:
- [terraform](./terraform/) contains terraform for provisioning the Engineering Sandbox Account.
- [eksctl-clusters](./eksctl-clusters/) contians scripts, templates, flux configuration, and clusters created by eksctl.

## Using SOPS to encrypt secrets
We use [SOPS](https://github.com/mozilla/sops) to encrypt our secrets. Shared secrets under `eksctl-clusters/shared-secrets` are encrypted using AWS KMS key that's configured in `.sops.yaml` config. They are then decrypted into the cluster directly using flux kustomize-controller.

To encrypt secrets using SOPS:
- Add a new creation_rule entry in `.sops.yaml` and change the `path_regex` to match your secrets location
- Encrypt the secret using sops: `sops -e -i PATH-TO-YOUR-SECRET`
- Add your encrypted secrets under your cluster dir so that they're reconciled by flux
- Add a kustomization that point to your encrypted secrets path. Make sure you enable SOPS decryption in your kustomization. See [secrets-kustomization-tmp.yaml](eksctl-clusters/secrets-kustomization-tmp.yaml)

## Pre-Commit hooks

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
