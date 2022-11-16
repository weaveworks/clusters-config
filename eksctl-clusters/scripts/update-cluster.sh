#! /bin/bash

set -e

blnk=$(echo "$0" | sed 's/./ /g')
usage() {
  echo "Usage: $0 [--weave-version <CHART_VERSION> ]"
  echo "       $blnk [--weave-branch <BRANCH_NAME> ]"
  echo "       $blnk [-h|--help]"

  echo
  echo "  --weave-version CHART_VERSION     -- Select a specific helm chart version (currently supports enterprise charts only)"
  echo "  --weave-branch BRANCH_NAME        -- Select a specific git branch for installation (currently supports enterprise branches only)"
  echo "  -h|--help                         -- Print this help message and exit"

  exit 0
}

defaults(){
  export AWS_REGION="eu-north-1"
}

flags(){
  while test $# -gt 0
  do
    case "$1" in
    --weave-version)
        shift
        export WEAVE_VERSION="$1"
        ;;
    --weave-branch)
        shift
        export WEAVE_BRANCH="$1"
        ;;
    -h|--help)
        usage;;
    *) usage;;
    esac
    shift
  done
}

source ${BASH_SOURCE%/*}/colors.sh
source ${BASH_SOURCE%/*}/common-functions.sh
# -------------------------------------------------------------------
defaults
flags "$@"

# Get cluster name and other file paths
CURRENT_BRANCH=$(git branch --show-current)
CLUSTER_NAME=${CURRENT_BRANCH#cluster-}

export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}
export WGE_RELEASE_FILE="${PARENT_DIR}/apps/enterprise/enterprise-app/release.yaml"
export WGE_KUSTOMIZATION="${CLUSTER_DIR}/enterprise-kustomization.yaml"

if [[ ${CURRENT_BRANCH} != cluster* ]]
then
  echo -e "${ERROR} You have to checkout to the cluster's branch. Current branch is \"${CURRENT_BRANCH}\". "
  exit 1
fi
echo "Cluster Name: ${CLUSTER_NAME}"

CHECK_ENTERPRISE_MODE=$(ls -d ${WGE_KUSTOMIZATION} 2> /dev/null || true )
if [ ${CHECK_ENTERPRISE_MODE} ]
then
  export WW_MODE="enterprise"
fi

# Validate flags
validateFlags

# Upgrade WGE version/branch
if [ "${WEAVE_BRANCH}" ]
then
  echo "Using WGE from branch: ${WEAVE_BRANCH}"
  sedi 's/version: .*/version: ">= 0.0.0-0"/g' ${WGE_RELEASE_FILE}

  CHART_REPO="https://charts.dev.wkp.weave.works/dev/branches/${WEAVE_BRANCH}"
  sedi 's#CHART_REPO: .*#CHART_REPO: '${CHART_REPO}'#g' ${WGE_KUSTOMIZATION}
elif [ "${WEAVE_VERSION}" ]
then
  echo "Using WGE version: ${WEAVE_VERSION}"
  sedi 's/version: .*/version: "'"${WEAVE_VERSION}"'"/g' ${WGE_RELEASE_FILE}

  CHART_REPO="https://charts.dev.wkp.weave.works/releases/charts-v3"
  sedi 's#CHART_REPO: .*#CHART_REPO: '${CHART_REPO}'#g' ${WGE_KUSTOMIZATION}
fi

echo -e "${SUCCESS} Your changes are ready! Please commit the changes and push them to your branch. Flux will reconcile all changes!"
