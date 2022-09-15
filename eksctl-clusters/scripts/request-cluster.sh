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

# -------------------------------------------------------------------

defaults
flags "$@"
export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}

export EKS_CLUSTER_TEMP=${PARENT_DIR}/eks-cluster-tmp.yaml

if [ -z $CLUSTER_NAME ]
then
  echo "No cluster name provided. Use '--cluster-name YOUR-CLUSTER' to set your cluster name."
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
else
  echo "A branch with name ${BRANCH_NAME} already exists. Please choose another name!"
  exit 1
fi

# Check that the cluster dir does not exist:
if [ -d "${CLUSTER_DIR}" ]
then
  echo "A cluster with name ${CLUSTER_NAME} already exists. Please choose another name!"
  exit 1
fi
mkdir -p ${CLUSTER_DIR}

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

# Copy WGE/WG-Core files
case $WW_MODE in
  core)
    echo "Copying WG-Core templates..."
    mkdir -p ${CLUSTER_DIR}/management
    cp -r ${PARENT_DIR}/wg-core-templates/* ${CLUSTER_DIR}/management/

    USERNAME="admin"
    PASSWORDHASH='$2a$10$IkS7eytRKSQewngdRn9fY.ahSv22C66M1OlCIfHURRJ4UM9BK1tcu' # adminpass

    echo "Username: $USERNAME, Password: adminpass"
    ${SED_} 's/${USERNAME}/'"${USERNAME}"'/g' ${CLUSTER_DIR}/management/ww-gitops.yaml
    ${SED_} 's/${PASSWORDHASH}/'"${PASSWORDHASH}"'/g' ${CLUSTER_DIR}/management/ww-gitops.yaml
    ;;
  enterprise)
    echo "Copying WGE templates..."
    mkdir -p ${CLUSTER_DIR}/management
    cp -r ${PARENT_DIR}/wge-templates/* ${CLUSTER_DIR}/management/
    ;;
  none)
    echo "Neither WG-Core nor WGE will be installed. Cluster will be provisioned with Flux only!"
    ;;
esac

# Copy core apps to cluster dir
cp -r ${PARENT_DIR}/apps/core/core-kustomization.yaml ${CLUSTER_DIR}/management/core-kustomization.yaml

echo "Cluster \"${CLUSTER_DIR}\" has been created"
echo "Please, commit the files and create a PR to provision the cluster"
