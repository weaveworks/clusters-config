# eksctl-clusters
This directory contians scripts, templates, flux configuration, and clusters created by eksctl.

## Requesting a new cluster
To request a new cluster, follow [this doc](../docs/cluster.md#requesting-a-cluster).

## Structure:
| Directory       | Description |
|--               |--           |
| [apps](./apps/) | where we keep apps config files. |
| [clusters](./clusters/)| where we save all data related to a created cluster. **Flux** will be connected to this repo and add its files to the **eksctl-clusters/clusters/CLUSTER_NAME** dir. |
| [policies](./policies/) | where the default policies live. Any new policies can be added here and reconciled by Flux |
| [scripts](./scripts/) | where all of our scripts will live. |
| [shared-secrets](./shared-secrets/) | where we save secrets that are shared for all clusters. like, entitlement-secret.yaml |
| [templates](./templates/) | where we keep all templates that we use |
| [eks-cluster.yaml-template](./eks-cluster.yaml-template) | the eks cluster template that will be use in creating the eks cluster. It will be copied under each cluster dir.|
| [flux-kustomization.yaml-template](./flux-kustomization.yaml-template) | the flux kustomization template that is used to patch flux controllers on bootstrapping. It will be copied under each cluster dir. |
| [secrets-kustomization.yaml-template](./secrets-kustomization.yaml-template) | the shared-secrets kustomization template that references the encrypted shared-secrets dir. It will be copied under each cluster dir.

## Using SOPS to encrypt secrets
We use [SOPS](https://github.com/mozilla/sops) to encrypt our secrets. Shared secrets in the `shared-secrets` dir are encrypted using AWS KMS key that's configured in `.sops.yaml` config (in the root of the repo). They are then decrypted into the cluster directly using flux kustomize-controller.

To encrypt secrets using SOPS:
- Install SOPS:
    ```
    curl --silent --location "https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.$(uname -s).amd64" --output sops
    chmod +x ./sops
    mv ./sops /usr/local/bin
    sops -v
    ```
- Add a new creation_rule entry in `.sops.yaml`. Change the `path_regex` to match your secrets location
- Encrypt the secret using sops: `sops -e -i PATH-TO-YOUR-SECRET`
- Add your encrypted secrets under your cluster dir so that they're reconciled by flux
- Add a kustomization that point to your encrypted secrets path. Make sure you enable SOPS decryption in your kustomization. See [secrets-kustomization.yaml-template](./secrets-kustomization.yaml-template)
