#! /bin/bash

# How to use:
#   run ./request-cluster.sh --cluster-name CLUSTER_NAME --cluster-version 1.23 --weave-mode core

set -e

blnk=$(echo "$0" | sed 's/./ /g')
usage() {
  echo "Usage: $0 --cluster-name <CLUSTER_NAME> \\"
  echo "       $blnk [--cluster-version <CLUSTER_VERSION>] \\"
  echo "       $blnk [--weave-mode <enterprise|core|none> {default core}]"
  echo "       $blnk [--enable-flagger]"
  echo "       $blnk [--delete-after {default 15}]"
  echo "       $blnk [-h|--help]"

  echo
  echo "  --cluster-name CLUSTER_NAME           -- Set cluster name"
  echo "  --cluster-version CLUSTER_VERSION     -- Set cluster version (default: 1.23)"
  echo "  --weave-mode <enterprise|core|none>   -- Select between installing WGE, WG-Core, or not install any (enterprise|core|none)"
  echo "  --enable-flagger                      -- Flagger will be installed on the cluster (only available when --weave-mode=enterprise)"
  echo "  --delete-after                        -- Cluster will be auto deleted after this number of days (default: 15)"
  echo "  -h|--help                             -- Print this help message and exit"

  exit 0
}

defaults(){
  export CLUSTER_VERSION="1.23"
  export WW_MODE="core"
  export ENABLE_FLAGGER="false"
  export DELETE_AFTER="15"
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
    --weave-mode)
        shift
        export WW_MODE="$1"
        if [ "${WW_MODE}" != "core" ] && [ "${WW_MODE}" != "enterprise" ] && [ "${WW_MODE}" != "none" ]
        then
          echo -e "${ERROR} Invalid value of --weave-mode = ${WW_MODE}. Please select one of (enterprise, core or none)!"
          exit 1
        fi
        ;;
    --enable-flagger)
        export ENABLE_FLAGGER="true"
        ;;
    --delete-after)
        shift
        export DELETE_AFTER="$1"
        # Check that delete-after is only numbers
        if [[ ! "${DELETE_AFTER}" =~ ^[0-9]+$ ]]
        then
            echo -e "${ERROR} Invalid value of --delete-after. It should contain only numbers"
            exit 1
        fi
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
export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}

export EKS_CLUSTER_TEMPLATE=${PARENT_DIR}/eks-cluster.yaml-template
export EKS_CLUSTER_CONFIG_FILE=${PARENT_DIR}/clusters/${CLUSTER_NAME}-eksctl-cluster.yaml

export FLUX_KUSTOMIZATION_TEMPLATE=${PARENT_DIR}/flux-kustomization.yaml-template
export SECRETS_KUSTOMIZATION_TEMPLATE=${PARENT_DIR}/secrets-kustomization.yaml-template

if [ -z $CLUSTER_NAME ]
then
  echo -e "${ERROR} No cluster name provided. Use '--cluster-name YOUR-CLUSTER' to set your cluster name."
  exit 1
fi

if [ $ENABLE_FLAGGER == "true" ] && [ "${WW_MODE}" != "enterprise" ]
then
  echo -e "${ERROR} --enable-flagger can only be used with --weave-mode=enterprise."
  exit 1
fi

echo "Cluster name: $CLUSTER_NAME, Cluster version: $CLUSTER_VERSION, Weave mode: $WW_MODE"

# Create new branch for the cluster
BRANCH_NAME="cluster-${CLUSTER_NAME}"
echo "Creating the cluster branch '${BRANCH_NAME}'"
git fetch --prune origin

BRANCH_EXISTS=$(git branch -a -l ${BRANCH_NAME})
BRANCH_EXISTS="${BRANCH_EXISTS//\*}"
if [ -z $BRANCH_EXISTS ]
then
  git checkout -b ${BRANCH_NAME}
  echo -e "${SUCCESS} ${BRANCH_NAME} branch is created successfully."
else
  echo -e "${ERROR} A branch with name ${BRANCH_NAME} already exists. Please choose another name!"
  exit 1
fi

# Check that the cluster dir does not exist:
if [ -d "${CLUSTER_DIR}" ]
then
  echo -e "${ERROR} A cluster with name ${CLUSTER_NAME} already exists. Please choose another name!"
  exit 1
fi

# Creating cluster directory
mkdir -p ${CLUSTER_DIR}
echo -e "${SUCCESS} '${CLUSTER_DIR}' created successfully."

if [ "$(uname -s)" == "Linux" ]; then
  SED_="sed -i"
elif [ "$(uname -s)" == "Darwin" ]; then
  SED_="sed -i ''"
fi

# Copy eksctl config to cluster dir
echo "Copying eksctl config file..."
cp ${EKS_CLUSTER_TEMPLATE} ${EKS_CLUSTER_CONFIG_FILE}
${SED_} 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
${SED_} 's/${CLUSTER_VERSION}/'"${CLUSTER_VERSION}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
${SED_} 's/${BRANCH_NAME}/'"${BRANCH_NAME}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
${SED_} 's/${DELETE_AFTER}/'"${DELETE_AFTER}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
echo -e "${SUCCESS} '${EKS_CLUSTER_CONFIG_FILE}' is created successfully."

# Copy common apps to cluster dir
echo "Copying apps-common templates..."
cp -r ${PARENT_DIR}/apps/common/common-kustomization.yaml-template ${CLUSTER_DIR}/common-kustomization.yaml

# Copy WGE/WG-Core files
case $WW_MODE in
  core)
    USERNAME="wego-admin"
    PASSWORDHASH='$2a$10$6ErJr5BDz4xpS9QxtqeveuEl9.1bioDeRHFLNgqP31oTYNht3EC.a' # password

    echo "Copying WeaveGitops templates..."
    cp -r ${PARENT_DIR}/apps/gitops/gitops-kustomization.yaml-template ${CLUSTER_DIR}/gitops-kustomization.yaml
    ${SED_} 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml

    ${SED_} 's/${USERNAME}/'"${USERNAME}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml
    ${SED_} 's/${PASSWORDHASH}/'"${PASSWORDHASH}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml
    ;;
  enterprise)
    echo "Copying WGE templates..."
    cp -r ${PARENT_DIR}/apps/enterprise/enterprise-kustomization.yaml-template ${CLUSTER_DIR}/enterprise-kustomization.yaml
    ${SED_} 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/enterprise-kustomization.yaml
    ${SED_} 's/${BRANCH_NAME}/'"${BRANCH_NAME}"'/g' ${CLUSTER_DIR}/enterprise-kustomization.yaml

    # cp -r ${PARENT_DIR}/templates/* ${CLUSTER_DIR}/
    # ${SED_} 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/templates-kustomization.yaml
    if [ $ENABLE_FLAGGER == "true" ]
    then
      cp -r ${PARENT_DIR}/apps/flagger/flagger-kustomization.yaml-template ${CLUSTER_DIR}/flagger-kustomization.yaml
    fi
    ;;
  none)
    echo -e "${WARNING} Neither WG-Core nor WGE will be installed. Cluster will be provisioned with Flux only!"
    ;;
esac

# Copy secrets
cp ${SECRETS_KUSTOMIZATION_TEMPLATE} ${CLUSTER_DIR}/secrets-kustomization.yaml

# Setup SOPS decryption for flux kustomize-controller
mkdir -p ${CLUSTER_DIR}/flux-system
touch ${CLUSTER_DIR}/flux-system/gotk-components.yaml \
    ${CLUSTER_DIR}/flux-system/gotk-sync.yaml
cp ${FLUX_KUSTOMIZATION_TEMPLATE} ${CLUSTER_DIR}/flux-system/kustomization.yaml
${SED_} 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/flux-system/kustomization.yaml

echo -e "${SUCCESS} Cluster directory \"${CLUSTER_DIR}\" has been created"
echo -e "          Please, commit the files and create a PR to provision the cluster"
