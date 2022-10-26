#! /bin/bash

# How to use:
#      run ./provision-cluster.sh --cluster-name CLUSTER_NAME

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

source ${BASH_SOURCE%/*}/colors.sh
# -------------------------------------------------------------------
defaults
flags "$@"

if [ -z $CLUSTER_NAME ]
then
  echo -e "${ERROR} No cluster name provided. Use '--cluster-name YOUR-CLUSTER' to set your cluster name."
  exit 1
fi

export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}
export EKS_CLUSTER_CONFIG_FILE=${PARENT_DIR}/clusters/${CLUSTER_NAME}-eksctl-cluster.yaml

# Check if GITHUB_TOKEN is set
if [ -z ${GITHUB_TOKEN} ]; then
  echo -e "${ERROR} Please export your GITHUB_TOKEN so flux can bootstrap!"
  exit 1
fi

# Check if the cluster aleady exists in AWS
export CLUSTER_EXISTS=$(eksctl get clusters --region ${AWS_REGION} -n ${CLUSTER_NAME} 2> /dev/null)
if [ -z $CLUSTER_EXISTS ]; then
  # Create EKS cluster
  eksctl create cluster -f ${EKS_CLUSTER_CONFIG_FILE}
else
  echo -e "${ERROR} Cluster with name '${CLUSTER_NAME}' already exists in AWS!"
  exit 1
fi

echo -e "${SUCCESS} The cluster is ready."
