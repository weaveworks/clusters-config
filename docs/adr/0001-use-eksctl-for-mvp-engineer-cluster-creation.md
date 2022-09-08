# [0001] Use Eksctl For MVP Engineer Cluster Creation

## Context

As covered in the [design docs](https://docs.google.com/document/d/1AMy-gCRpPzVKS0IAF91HLPFSrymBox-eh5FUjw6ccrk)
there is a general need for engineers to be able to easily provision kubernetes
clusters in an automated and repeatable manner. This also enables future use
cases for, e.g. automated testing and templated workloads.

There were 4 potential solutions presented in the design doc:
* Providing a set of eksctl configuration files and mechanisms to deploy them
* Deploying Weave Gitops Enterprise with CAPI installed and a set of profiles
* Creating a custom stateless solution
* Creating a custom stateful solution

## Decision

Initially we will build a set of eksctl configuration files and scripts that will
enable creation and destruction of simple EKS clusters.

## Consequences

We will likely have to replace this solution as our understanding of our needs
matures.

The work should be done such that it supports changing away from eksctl (likely
to Weave Gitops Enterprise). A good proportion of the work should be transferable
from one solution to the other (for example account configuration, Flux files
for deploying Gitops).
