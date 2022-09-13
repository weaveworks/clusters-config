#! /bin/bash

# How to use:
#      run ./request-cluster.sh --cluster-name CLUSTER_NAME --cluster-version 1.23 --weave-mode core

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
  echo "  --weave-mode <enterprise|core|none>   -- Select between installing WW Enterprise, WW Core, or not install any (enterprise|core|none)"
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
  echo "You have to enter the cluster name. Use -h for help."
  exit 1
fi

echo "cluster name: $CLUSTER_NAME, cluster version: $CLUSTER_VERSION, weave mode: $WW_MODE"

# check that the cluster dir is not exist:
if [ -d "${CLUSTER_DIR}" ]
then
  echo "A cluster with the same name is found. Please choose another name!"
  exit 1
fi
mkdir -p ${CLUSTER_DIR}

# copy eksctl config to cluster dir
echo "Coping eksctl config file..."
cp ${EKS_CLUSTER_TEMP} ${CLUSTER_DIR}/eksctl-cluster.yaml
if [ "$(uname -s)" == "Linux" ]; then
  sed -i 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/eksctl-cluster.yaml
  sed -i 's/${CLUSTER_VERSION}/'"${CLUSTER_VERSION}"'/g' ${CLUSTER_DIR}/eksctl-cluster.yaml
elif [ "$(uname -s)" == "Darwin" ]; then
  sed -i '' 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/eksctl-cluster.yaml
  sed -i '' 's/${CLUSTER_VERSION}/'"${CLUSTER_VERSION}"'/g' ${CLUSTER_DIR}/eksctl-cluster.yaml
fi

# copy WGE files
case $WW_MODE in
  core)
    echo "Coping WW-Core templates..."
    mkdir -p ${CLUSTER_DIR}/management
    cp -r ${PARENT_DIR}/wg-core-templates/* ${CLUSTER_DIR}/management/

    USERNAME="admin"
    PASSWORDHASH='$2a$10$IkS7eytRKSQewngdRn9fY.ahSv22C66M1OlCIfHURRJ4UM9BK1tcu' # adminpass

    echo "username: $USERNAME, password: adminpass"
    if [ "$(uname -s)" == "Linux" ]; then
      sed -i 's/${USERNAME}/'"${USERNAME}"'/g' ${CLUSTER_DIR}/management/ww-gitops.yaml
      sed -i 's/${PASSWORDHASH}/'"${PASSWORDHASH}"'/g' ${CLUSTER_DIR}/management/ww-gitops.yaml
    elif [ "$(uname -s)" == "Darwin" ]; then
      sed -i '' 's/${USERNAME}/'"${USERNAME}"'/g' ${CLUSTER_DIR}/management/ww-gitops.yaml
      sed -i '' 's/${PASSWORDHASH}/'"${PASSWORDHASH}"'/g' ${CLUSTER_DIR}/management/ww-gitops.yaml
    fi
    ;;
  enterprise)
    echo "Coping WGE templates..."
    mkdir -p ${CLUSTER_DIR}/management
    cp -r ${PARENT_DIR}/wge-templates/* ${CLUSTER_DIR}/management/
    ;;
  none)
    echo "We will not install WW-core or WGE!"
    ;;
esac


echo "Cluster \"${CLUSTER_DIR}\" has been created"
echo "Please, commit the files and create a PR to provision the cluster"
