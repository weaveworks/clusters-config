#! /bin/bash

# How to use:
#      run ./extend-cluster-ttl.sh --cluster-name CLUSTER_NAME --extend <NUMBER_OF_DAYS_TO_BE_EXTENDED>

set -e

blnk=$(echo "$0" | sed 's/./ /g')
usage() {
  echo "Usage: $0 --cluster-name <CLUSTER_NAME> --extend <NUMBER_OF_DAYS_TO_BE_EXTENDED>\\"
  echo "       $blnk [-h|--help]"

  echo
  echo "  --cluster-name CLUSTER_NAME              -- Set cluster name"
  echo "  --extend NUMBER_OF_DAYS_TO_BE_EXTENDED   -- Set cluster name"
  echo "  -h|--help                                -- Print this help message and exit"

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
    --extend)
        shift
        export DAYS="$1"
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

sedi () {
    case $(uname -s) in
        *[Dd]arwin* | *BSD* ) sed -i '' "$@";;
        *) sed -i "$@";;
    esac
}

export PARENT_DIR=${BASH_SOURCE%/scripts*}
export EKS_CLUSTER_CONFIG_FILE=${PARENT_DIR}/clusters/${CLUSTER_NAME}-eksctl-cluster.yaml

if [ -z $CLUSTER_NAME ]
then
  echo -e "${ERROR} No cluster name provided. Use '--cluster-name YOUR-CLUSTER' to set your cluster name."
  exit 1
fi

re='^[0-9]+$'
if ! [[ $DAYS =~ $re ]] ; then
    echo -e "${ERROR} Not a number. Please enter the number of days to be extended"
    exit 1
fi

CLUSTER_ARN=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.arn" --output text)
DELETE_AFTER=$(aws eks list-tags-for-resource --resource-arn $CLUSTER_ARN --query 'tags."delete-after"' --output text)
EXTENDED_DELETE_AFTER=$(($DELETE_AFTER + $DAYS))

if grep -q "delete-after: $DELETE_AFTER" $EKS_CLUSTER_CONFIG_FILE; then # delete-after tag exists?
    sedi 's/delete-after: '${DELETE_AFTER}'/delete-after: '${EXTENDED_DELETE_AFTER}'/g' ${EKS_CLUSTER_CONFIG_FILE} # modify delete-after tag
else
    echo -e "${WARNING} delete-after tag does not exist in cluster config: ${EKS_CLUSTER_CONFIG_FILE}"
    echo -e "          Please, add it to your eksctl cluster config file and push to your cluster branch. You can get it's value from the AWS Console."
fi

aws eks tag-resource --resource-arn $CLUSTER_ARN --tags delete-after=$EXTENDED_DELETE_AFTER

echo -e "${SUCCESS} Cluster delete-after tag has been updated to be ${EXTENDED_DELETE_AFTER} days."
echo -e "          Please, commit your updated eksctl cluster config file and push it to your cluster branch"
