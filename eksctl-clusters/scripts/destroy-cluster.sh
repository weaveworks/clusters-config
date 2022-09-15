#! /bin/bash

# How to use:
#      run ./destroy-cluster.sh --cluster-name CLUSTER_NAME

set -e

blnk=$(echo "$0" | sed 's/./ /g')
usage() {
  echo "Usage: $0 --cluster-name <CLUSTER_NAME> \\"
  echo "       $blnk [-h|--help]"

  echo
  echo "  --cluster-name CLUSTER_NAME           -- Set cluster name"
  echo "  -h|--help                             -- Print this help message and exit"

  exit 0
}

defaults(){
  export AWS_REGION="eu-north-1"
}

flags(){
  while test $# -gt 0
  do
    case "$1" in
    --cluster-name)
        shift
        export CLUSTER_NAME="$1"
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

if [ -z $CLUSTER_NAME ]
then
  echo "No cluster name provided. Use '--cluster-name YOUR-CLUSTER' to set your cluster name."
  exit 1
fi

export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}
CONFIG_FILE=${CLUSTER_DIR}/eksctl-cluster.yaml


export CLUSTER_EXISTS=$(eksctl get clusters --region ${AWS_REGION} -n ${CLUSTER_NAME} 2> /dev/null)
if [ -z $CLUSTER_EXISTS ]; then
  echo "Could not find cluster '${CLUSTER_NAME}' to delete."
  exit 1
else
  # Delete EKS cluster
  echo "Deleting ${CLUSTER_NAME} cluster"
  eksctl delete cluster -f ${CONFIG_FILE}
fi
