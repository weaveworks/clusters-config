#! /bin/bash

# How to use:
#   run ./request-cluster.sh --cluster-name CLUSTER_NAME --cluster-version 1.23 --weave-mode core

set -e

blnk=$(echo "$0" | sed 's/./ /g')
usage() {
  echo "Usage: $0 --cluster-name <CLUSTER_NAME> \\"
  echo "       $blnk [--cluster-version <CLUSTER_VERSION>] \\"
  echo "       $blnk [--weave-mode <enterprise|core|none> {default core}]"
  echo "       $blnk [-h|--help]"

  echo
  echo "  --cluster-name CLUSTER_NAME           -- Set cluster name"
  echo "  --cluster-version CLUSTER_VERSION     -- Set cluster version (default: 1.23)"
  echo "  --weave-mode <enterprise|core|none>   -- Select between installing WGE, WG-Core, or not install any (enterprise|core|none)"
  echo "  -h|--help                             -- Print this help message and exit"

  exit 0
}

defaults(){
  export CLUSTER_VERSION="1.23"
  export WW_MODE="core"
}

flags(){
  while test $# -gt 0
  do
    case "$1" in
    --cluster-name)
        shift
        export CLUSTER_NAME="$1"
        ;;
    --cluster-version)
        shift
        export CLUSTER_VERSION="$1"
        ;;
    --weave-mode)
        shift
        export WW_MODE="$1"
        if [ "${WW_MODE}" != "core" ] && [ "${WW_MODE}" != "enterprise" ] && [ "${WW_MODE}" != "none" ]
        then
          echo "Invalid value of --weave-mode = ${WW_MODE}. Please select one of (enterprise, core or none)!"
          exit 1
        fi
        ;;
    -h|--help)
        usage;;
    *) usage;;
    esac
    shift
  done
}

source ${BASH_SOURCE%/*}/colors.sh
# -------------------------------------------------------------------

defaults
flags "$@"
export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}

export EKS_CLUSTER_TEMP=${PARENT_DIR}/eks-cluster-tmp.yaml
export FLUX_KUSTOMIZATION_TEMP=${PARENT_DIR}/flux-kustomization-tmp.yaml
export SECRETS_KUSTOMIZATION_TEMP=${PARENT_DIR}/secrets-kustomization-tmp.yaml

if [ -z $CLUSTER_NAME ]
then
  echo -e "${ERROR} No cluster name provided. Use '--cluster-name YOUR-CLUSTER' to set your cluster name."
  exit 1
fi

echo "Cluster name: $CLUSTER_NAME, Cluster version: $CLUSTER_VERSION, Weave mode: $WW_MODE"

# Create new branch for the cluster
BRANCH_NAME="cluster-${CLUSTER_NAME}"
echo "Creating the cluster branch '${BRANCH_NAME}'"
git fetch --prune origin

BRANCH_EXISTS=$(git branch -a -l ${BRANCH_NAME})
BRANCH_EXISTS="${BRANCH_EXISTS//\*}"
if [ -z $BRANCH_EXISTS ]
then
  git checkout -b ${BRANCH_NAME}
  echo -e "${SUCCESS} ${BRANCH_NAME} branch is created successfully."
else
  echo -e "${ERROR} A branch with name ${BRANCH_NAME} already exists. Please choose another name!"
  exit 1
fi

# Check that the cluster dir does not exist:
if [ -d "${CLUSTER_DIR}" ]
then
  echo -e "${ERROR} A cluster with name ${CLUSTER_NAME} already exists. Please choose another name!"
  exit 1
fi

# Creating cluster directory
mkdir -p ${CLUSTER_DIR}/management
echo -e "${SUCCESS} '${CLUSTER_DIR}' created successfully."

if [ "$(uname -s)" == "Linux" ]; then
  SED_="sed -i"
elif [ "$(uname -s)" == "Darwin" ]; then
  SED_="sed -i ''"
fi

# Copy eksctl config to cluster dir
echo "Copying eksctl config file..."
cp ${EKS_CLUSTER_TEMP} ${CLUSTER_DIR}/eksctl-cluster.yaml
${SED_} 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/eksctl-cluster.yaml
${SED_} 's/${CLUSTER_VERSION}/'"${CLUSTER_VERSION}"'/g' ${CLUSTER_DIR}/eksctl-cluster.yaml
${SED_} 's/${BRANCH_NAME}/'"${BRANCH_NAME}"'/g' ${CLUSTER_DIR}/eksctl-cluster.yaml
echo -e "${SUCCESS} '${CLUSTER_DIR}/eksctl-cluster.yaml' is created successfully."

# Copy core apps to cluster dir
echo "Copying apps-core templates..."
cp -r ${PARENT_DIR}/apps/core/* ${CLUSTER_DIR}/management/

# Copy WGE/WG-Core files
case $WW_MODE in
  core)
    echo "Copying WeaveGitops templates..."
    cp -r ${PARENT_DIR}/apps/gitops/* ${CLUSTER_DIR}/management/

    USERNAME="wego-admin"
    PASSWORDHASH='$2a$10$zro7niJ73Z.OZ0JiLkQyJOIkfM.hpNGIm.7fCR1sVbKwY/ReX6Wci' # password

    echo "Username: $USERNAME, Password: adminpass"
    ${SED_} 's/${USERNAME}/'"${USERNAME}"'/g' ${CLUSTER_DIR}/management/gitops-app/gitops.yaml
    ${SED_} 's/${PASSWORDHASH}/'"${PASSWORDHASH}"'/g' ${CLUSTER_DIR}/management/gitops-app/gitops.yaml
    ;;
  enterprise)
    echo "Copying WGE templates..."
    cp -r ${PARENT_DIR}/apps/enterprise/* ${CLUSTER_DIR}/management/
    ;;
  none)
    echo -e "${WARNING} Neither WG-Core nor WGE will be installed. Cluster will be provisioned with Flux only!"
    ;;
esac

# Copy secrets
cp ${SECRETS_KUSTOMIZATION_TEMP} ${CLUSTER_DIR}/management/secrets-kustomization.yaml

# Setup SOPS decryption for flux kustomize-controller
mkdir -p ${CLUSTER_DIR}/management/flux-system
touch ${CLUSTER_DIR}/management/flux-system/gotk-components.yaml \
    ${CLUSTER_DIR}/management/flux-system/gotk-sync.yaml
cp ${FLUX_KUSTOMIZATION_TEMP} ${CLUSTER_DIR}/management/flux-system/kustomization.yaml
${SED_} 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/management/flux-system/kustomization.yaml

echo -e "${SUCCESS} Cluster directory \"${CLUSTER_DIR}\" has been created"
echo -e "          Please, commit the files and create a PR to provision the cluster"
