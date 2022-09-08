#! /bin/bash

# How to use:
#      run ./provision-cluster.sh CLUSTER_NAME

CLUSTER_NAME=$1
if [ -z $1 ]
then
  echo "You have to enter the cluster name."
  exit 1
fi

export AWS_REGION="eu-north-1"
export WW_ADMIN_ARN="arn:aws:iam::894516026745:role/AdministratorAccess"

export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}
CONFIG_FILE=${CLUSTER_DIR}/eksctl-cluster.yaml

# Chech if GITHUB_TOKEN is set
if [ -z $GITHUB_TOKEN ]; then
  echo "Please export your GITHUB_TOKEN so flux can bootstrap!"
  exit 1
else 

# Check if the cluster exists from AWS
export CLUSTER_EXISTS=$(eksctl get clusters --region ${AWS_REGION}| grep -i ${CLUSTER_NAME})
if [ -z $CLUSTER_EXISTS ]; then
  # Create EKS cluster
  eksctl create cluster -f ${CONFIG_FILE}
else
  echo "There is a cluster created with the same name"
  exit 1
fi

# Add WW roles to aws-auth
echo "Add ${WW_ADMIN_ARN} to aws-auth"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --arn ${WW_ADMIN_ARN} --group system:masters --username admin
