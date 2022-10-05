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

if [ "$(uname -s)" == "Linux" ]; then
  SED_="sed -i"
elif [ "$(uname -s)" == "Darwin" ]; then
  SED_="sed -i ''"
fi

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
TTL=$(aws eks list-tags-for-resource --resource-arn $CLUSTER_ARN --query "tags.ttl" --output text)
EXTENDED_TTL=$(($TTL + $DAYS))

if grep -q "ttl: $TTL" $EKS_CLUSTER_CONFIG_FILE; then # ttl tag exists?
    ${SED_} 's/ttl: '${TTL}'/ttl: '${EXTENDED_TTL}'/g' ${EKS_CLUSTER_CONFIG_FILE} # modify ttl tag
else
    ${SED_} 's/  tags:/  tags:\n\t\tttl: '${EXTENDED_TTL}'/g' ${EKS_CLUSTER_CONFIG_FILE} # add ttl tag
fi

aws eks tag-resource --resource-arn $CLUSTER_ARN --tags ttl=$EXTENDED_TTL

echo -e "${SUCCESS} Cluster TTL has been updated to be ${EXTENDED_TTL} days."
echo -e "          Please, commit your updated eksctl cluster config file and push it to your cluster branch"
