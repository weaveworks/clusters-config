#! /bin/bash

# Install Fluxcd
## Flux is installed by default using eksctl. We should ass the installation steps for other solutions.

# Install clusterctl
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.1.4/clusterctl-linux-amd64 -o clusterctl
chmod +x ./clusterctl
sudo mv ./clusterctl /usr/local/bin/clusterctl
clusterctl versio

