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
  export WW_ADMIN_ARN="arn:aws:iam::894516026745:role/AdministratorAccess"
  export WW_EDITOR_ARN="arn:aws:iam::894516026745:role/WeaveEksEditor"
  export WW_GITHUB_ACTIONS_ARN="arn:aws:iam::894516026745:role/WeaveEksGithubActions"
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

waitDNSRecordCreated(){
  until [ "$(dig +short $1)" != "" ];
  do
    echo "Waiting for domain to be available: $1"
    sleep 30
  done
  echo -e "${SUCCESS} Domain is ready: $1"
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
export WGE_KUSTOMIZATION="${CLUSTER_DIR}/enterprise-kustomization.yaml"
export WGCORE_KUSTOMIZATION="${CLUSTER_DIR}/gitops-kustomization.yaml"

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

# Add WW roles to aws-auth
echo "Add weaveworks roles to aws-auth"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --arn ${WW_ADMIN_ARN} --group system:masters --username admin
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --arn ${WW_EDITOR_ARN} --group system:masters --username admin
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --arn ${WW_GITHUB_ACTIONS_ARN} --group system:masters --username admin

timeout 20m cat <( waitDNSRecordCreated $CLUSTER_NAME-dex.eng-sandbox.weave.works. )
EXIT_CODE=$(echo $?)
if [ $EXIT_CODE -eq 124 ]
then
  echo -e "${ERROR} Timeout. Domain not ready: $CLUSTER_NAME-dex.eng-sandbox.weave.works."
  exit 1
fi

# Rollout WGE/WGCore to make sure it captures the dex domain on start up
CHECK_ENTERPRISE_MODE=$(ls -d ${WGE_KUSTOMIZATION} 2> /dev/null || true )
CHECK_WGCORE_MODE=$(ls -d ${WGCORE_KUSTOMIZATION} 2> /dev/null || true )
if [ ${CHECK_ENTERPRISE_MODE} ]
then
  kubectl rollout restart -n flux-system deployment weave-gitops-enterprise-cluster-controller || true
  kubectl rollout restart -n flux-system deployment weave-gitops-enterprise-mccp-cluster-bootstrap-controller || true
  kubectl rollout restart -n flux-system deployment weave-gitops-enterprise-mccp-cluster-service || true
elif [ ${CHECK_WGCORE_MODE} ]
then
  kubectl rollout restart -n flux-system deployment ww-gitops-weave-gitops || true
fi

echo -e "${SUCCESS} Cluster is ready!"
