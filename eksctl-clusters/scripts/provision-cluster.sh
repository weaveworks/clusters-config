#! /bin/bash

# How to use:
#      run ./provision-cluster.sh CLUSTER_NAME

CLUSTER_NAME=$1
if [ -z $1 ]
then
  echo "You have to enter the cluster name."
  exit 1
fi

CONFIG_FILE=clusters/${CLUSTER_NAME}/eksctl-cluster.yaml

# Check if the cluster exists from AWS
export CLUSTER_EXISTS=$(eksctl get clusters | grep -i $CLUSTER_NAME)
if [ -z $CLUSTER_EXISTS ]; then
  # Create EKS cluster
  eksctl create cluster -f ${CONFIG_FILE}
fi
