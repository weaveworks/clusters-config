# Bootstarp Flux on Leaf Cluster

## Context: 

When flux bootstrap, it uses the github-token to create a deploy key in the repo, so it can push its manifest to the repo. To do so, the github-token should belongs to a user with admin permission to the repo. Most of engineers have write or maintain access to "clusters-config" repo, so their tokens will not be able to create the deploy-key for Flux in the bootstrap process and flux will fail.

> **_Note:_** We can't make it work in cicd pipelines using our bot token because leaf clusters are not created in cicd.

## Potential Solutions:

1. [ **Copy managment cluster deploy key** ] Copy the management-cluster deploy key from the management cluster to the leaf cluster. "Includes manual bootstraping"
1. [ **Admin access for users** ] Ask for admin access from Ciaran. Access should be granted per user. => "it will solve the issue."
1. ~~[ **Different Repo** ] Bootstrap in different repo => "not acceptable!"~~
1. [ **Shared admin token** ] Share a token for a bot that have admin access to that repo. NOT RECOMMENDED as we should think of a way to rotate that token frequently. However, we can do it if the previous solutions are not applicable or impossible.

## Curenct Accepted Solution:

We have decided to go with [ **Copy managment cluster deploy key** ] solution. The idea is to copy the deploy-key secret from the management cluster to the leaf cluster, then run the bootstrap manually. Flux will use the management-cluster deploy-key instead of requiring access to create new one.

### Steps:

1. Download the leaf cluster kubeconfig and rename it to `leaf.kubeconfig`

1. From management cluster, copy flux-system secret into a file called `deploy-key.yaml`

    ```bash
    kubectl get secret flux-system -n flux-system -o yaml > deploy-key.yaml
    ```

1. Create namespace `flux-system` on the leaf cluster

    ```bash
    kubectl create ns flux-system --kubeconfig ./leaf.kubeconfig
    ```

1. Apply this secret to your leaf cluster

    ```bash
    kubectl apply -f deploy-key.yaml --kubeconfig ./leaf.kubeconfig -n flux-system
    ```

1. Replace variables in the follwoing command then use it to bootstrap flux.

    ```bash
    flux bootstrap github \
    --kubeconfig=./leaf.kubeconfig \
    --owner=weaveworks \
    --repository=clusters-config \
    --path=./eksctl-clusters/clusters/<management-cluster-name>/clusters/<leaf-cluster-namespace>/<leaf-cluster-name> \
    --branch=<management-cluster-branch> \
    --token-auth=false
    ```

Execution log example
```bash
➜  kubectl get po -A --kubeconfig leaf.kubeconfig     
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-59f89             1/1     Running   0          14m
kube-system   coredns-6c5cd9f6df-6hgn4   1/1     Running   0          19m
kube-system   coredns-6c5cd9f6df-bdrw7   1/1     Running   0          19m
kube-system   kube-proxy-2zmq4           1/1     Running   0          14m

➜  kubectl get secret -A --kubeconfig leaf.kubeconfig
No resources found

➜  kubectl create ns flux-system  --kubeconfig leaf.kubeconfig                     
namespace/flux-system created

➜  kubectl apply -f ../my-pat.yaml --kubeconfig leaf.kubeconfig -n flux-system
secret/flux-system created

➜  flux bootstrap github --kubeconfig=./leaf.kubeconfig --owner=weaveworks --repository=clusters-config --path=./eksctl-clusters/clusters/waleed-terraform/default/leaf --branch=cluster-waleed-terraform --token-auth=false
► connecting to github.com
► cloning branch "cluster-waleed-terraform" from Git repository "https://github.com/weaveworks/clusters-config.git"
✔ cloned repository
► generating component manifests
✔ generated component manifests
✔ committed sync manifests to "cluster-waleed-terraform" ("6f49fb3e0603c951fc0a979bf059503fc52ae747")
► pushing component manifests to "https://github.com/weaveworks/clusters-config.git"
► installing components in "flux-system" namespace
✔ installed components
✔ reconciled components
► determining if source secret "flux-system/flux-system" exists
✔ source secret up to date
► generating sync manifests
✔ generated sync manifests
✔ committed sync manifests to "cluster-waleed-terraform" ("8f5de234b5ba3d7a3fdf1fdd0610375bb1c99ae4")
► pushing sync manifests to "https://github.com/weaveworks/clusters-config.git"
► applying sync manifests
✔ reconciled sync configuration
◎ waiting for Kustomization "flux-system/flux-system" to be reconciled
✔ Kustomization reconciled successfully
► confirming components are healthy
✔ helm-controller: deployment ready
✔ kustomize-controller: deployment ready
✔ notification-controller: deployment ready
✔ source-controller: deployment ready
✔ all components are healthy
```