#! /bin/bash

# make-cluster.sh --cluster-name hamada --cluster-version 1.21

blnk=$(echo "$0" | sed 's/./ /g')
usage() {
  echo "Usage: $0 [{--cluster-name} cluster-name] [{--cluster-version} cluster-version] \\"
  echo "       $blnk [-h|--help]"

  echo
  echo "  {--cluster-name} cluster-name        -- Set cluster name"
  echo "  {--cluster-version} cluster-version  -- Set cluster version (default: 1.23)"
  echo "  {-h|--help}                          -- Print this help message and exit"

  exit 0
}

defaults(){
  export CLUSTER_VERSION="1.23"
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
  echo "You have to enter the cluster name."
  exit 1
fi

echo "cluster name: $CLUSTER_NAME, cluster version: $CLUSTER_VERSION"

# check that the cluster dir is not exist:
if [ -d "clusters/${CLUSTER_NAME}" ]
then 
  echo "A cluster with the same name is found. Please choose another name!"
  exit 1
fi

# create dir for the cluster
mkdir -p clusters/${CLUSTER_NAME}/management

# copy WGE files
echo "Coping WGE templates..."
cp -r wge-templates/* clusters/${CLUSTER_NAME}/management/


# copy eksctl config to cluster dir
echo "Coping eksctl config file..."
cp eks-cluster-tmp.yaml clusters/${CLUSTER_NAME}/eksctl-cluster.yaml
sed -i 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' clusters/${CLUSTER_NAME}/eksctl-cluster.yaml
sed -i 's/${CLUSTER_VERSION}/'"${CLUSTER_VERSION}"'/g' clusters/${CLUSTER_NAME}/eksctl-cluster.yaml

echo "Cluster \"clusters/${CLUSTER_NAME}\" has been created"
echo "Please, commit the files and create a PR to provision the cluster"
