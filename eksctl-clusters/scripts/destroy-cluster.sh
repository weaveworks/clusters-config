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

waitDNSRecordDeleted(){
  while :
  do
    records=$(aws route53 list-resource-record-sets --hosted-zone-id Z077228227PQNG000XADR --query "ResourceRecordSets[?Name == '$CLUSTER_NAME.eng-sandbox.weave.works.']")
    str=$(echo $records | sed -e 's/\[//g' -e 's/\]//g') # remove [] so that it turns into empty string ""
    if [[ "$str" != "" ]]; then
        echo "Waiting for domain to be deleted: $1"
        sleep 30
    else
        break
    fi
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
CONFIG_FILE=${CLUSTER_DIR}/eksctl-cluster.yaml


export CLUSTER_EXISTS=$(eksctl get clusters --region ${AWS_REGION} -n ${CLUSTER_NAME} 2> /dev/null)
if [ -z "$CLUSTER_EXISTS" ]; then
  echo -e "${ERROR} Could not find cluster '${CLUSTER_NAME}' to delete."
  exit 1
else
  echo "Deleting flux system"
  flux uninstall --silent --keep-namespace=true

  # Delete ingress resources to trigger external dns to delete Route53 records
  kubectl delete ingress -A --all
  waitDNSRecordDeleted $CLUSTER_NAME.eng-sandbox.weave.works.
  waitDNSRecordDeleted $CLUSTER_NAME-dex.eng-sandbox.weave.works.

  echo "Deleting capi clusters"
  kubectl delete cluster -A --all

  # Delete loadbalancers
  kubectl get svc -A -o custom-columns=NAME:.metadata.name,NS:.metadata.namespace,TYPE:.spec.type | \
   tr -s " " | \
   grep -i loadbalancer | \
   cut -d " " -f 1,2 | \
   awk -F ' ' '{print "Deleting " $1 " loadbalancer"};{system("kubectl delete service -n " $2 " " $1 )}'

  # Delete EKS cluster
  echo "Deleting ${CLUSTER_NAME} cluster"
  eksctl delete cluster --region ${AWS_REGION} --name ${CLUSTER_NAME}

  echo -e "${SUCCESS} ${CLUSTER_NAME} cluster is deleted successfully."
fi
