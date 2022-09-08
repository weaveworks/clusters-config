#! /bin/bash

CLUSTER_NAME=$1
if [ -z $1 ]
then
  echo "You have to enter the cluster name."
  exit 1
fi

export AWS_REGION="eu-north-1"

export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}
CONFIG_FILE=${CLUSTER_DIR}/eksctl-cluster.yaml


export CLUSTER_EXISTS=$(eksctl get clusters --region ${AWS_REGION} | grep -iw ${CLUSTER_NAME})
if [ -z $CLUSTER_EXISTS ]; then
  echo "There is no cluster with the provided name"
  exit 1
else
  # Delete EKS cluster
  echo "Deleting ${CLUSTER_NAME} cluster"
  eksctl delete cluster -f ${CONFIG_FILE}
fi
