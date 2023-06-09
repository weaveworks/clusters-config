```gherkin
Feature: Can Use Explorer with Flux GA
  As a weave gitops platform engineer
  I could use explorer after upgraded to Flux Ga

  Scenario Outline: Add two numbers <num1> & <num2>
    Given a resource <resourceName> from <gvk>
    When deployed to weave gitops
    Then I find it via Explorer

    Examples:
      | resourceName | gvk                                               |
      |              | kustomize.toolkit.fluxcd.io/v1/Kustomization      |
      |              | kustomize.toolkit.fluxcd.io/v1beta2/Kustomization |
      |              | source.toolkit.fluxcd.io/v1/GitRepository         |
      |              | source.toolkit.fluxcd.io/v1beta2/Kustomization    |

```

v1 resource

```
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: podinfo
  namespace: default
spec:
  interval: 5m
  url: https://github.com/stefanprodan/podinfo
  ref:
    branch: master
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: podinfo
  namespace: default
spec:
  interval: 10m
  targetNamespace: default
  sourceRef:
    kind: GitRepository
    name: podinfo
  path: "./kustomize"
  prune: true
  timeout: 1m
```
