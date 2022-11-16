# Upgrade WGE

- This document explaines how to switch between WGE released versions. Or switching between WGE released versions and WGE from a feature-branch. 

- This will give engineers the power to upgrade WGE and test the upgrade before releasing a new version.

### To upgrade:

1. Checkout to the cluster branch. The script will fail if you didn't!
1. Run the following command:
    ```bash
    ./eksctl-clusters/scripts/update-cluster.sh [--weave-branch WEAVE_BRANCH | --weave-version WEAVE_VERSION]
    ```

    > **_NOTE:_** You cann't use both "--weave-branch" and "--weave-version". Select only one.
