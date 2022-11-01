# Apps
Where we keep apps config files to be reconsiled by flux.

1. [**common**](./common/):
    Applications that will be installed by default. Like, [**dex**](./common/dex/) and [**podinfo**](./common/podinfo/) apps.

1. [**enterprise**](./enterprise/):
    Enterprise components that will be installed if you choose to install enterprise `--weave-mode enterprise`.

1. [**enterprise-leaf**](./enterprise-leaf/):
    Apps that will be installed if you choose to create leaf cluster `--weave-mode leaf`.

1. [**gitops**](./gitops/):
    gitops app will be installed if you choose to install gitops-core `--weave-mode core`.

1. [**flagger**](./flagger/):
    flagger and ingress apps will be installed if you choose to install flagger `--enable-flagger`.

**Note:**
Under each directory there is a `kustomization.yaml-template` file. We copy this file to your cluster directory. So you don't worry about them at all ;).
