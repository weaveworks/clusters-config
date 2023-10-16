#!/usr/bin/env bash

set -eo pipefail

unset CD_PATH
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}" || exit 1

CLUSTER_NAME=${1:-demo-01}

rsync -av "${SCRIPT_DIR}/../weave-gitops-enterprise/tools/dev-resources/" "${SCRIPT_DIR}/eksctl-clusters/clusters/demo-01/tilt-dev-resources"

# rm the base which is the password
rm "${SCRIPT_DIR}/eksctl-clusters/clusters/demo-01/tilt-dev-resources/base.yaml"
