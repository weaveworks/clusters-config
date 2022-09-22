# Apps
Where we keep apps config files to be reconsiled by flux.

There are 3 catagories for apps:

1. [**Core**](./core/):
    Applications that will be installed by default. Like, [**dex**](./core/dex/) and [**podinfo**](./core/podinfo/) apps.

1. [**Enterprise**](./enterprise/):
    Enterprise components that will be installed if you choose to install enterprise `--weave-mode enterprise`.

1. [**Gitops**](./gitops/):
    gitops app will be installed if you choose to install gitops-core `--weave-mode core`.


**Note:**
Under each directory there is a `kustomization.yaml-template` file. We copy this file to your cluster directory. So you don't worry about them at all ;).
