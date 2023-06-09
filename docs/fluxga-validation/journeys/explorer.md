```gherkin
Feature: Can Use Explorer with Flux GA
  As a weave gitops platform engineer
  I could use explorer after upgraded to Flux Ga

  Scenario Outline:
    Given a resource <resourceName> from <gvk>
    When deployed to weave gitops
    Then I find it via Explorer

    Examples:
      | resourceName | gvk                                               |
      | podinfo-ga   | kustomize.toolkit.fluxcd.io/v1/Kustomization      |
      | podinfo-beta | kustomize.toolkit.fluxcd.io/v1beta2/Kustomization |
      | podinfo-ga   | source.toolkit.fluxcd.io/v1/GitRepository         |
      | podinfo-beta | source.toolkit.fluxcd.io/v1beta2/Kustomization    |

```

- Validation application [path](./eksctl-clusters/clusters/fluxga/validation-explorer.yaml)
- Validated that I could find the resources

![explorer.png](imgs%2Fexplorer.png)
