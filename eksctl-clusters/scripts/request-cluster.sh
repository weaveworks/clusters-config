#! /bin/bash

# How to use:
#   run ./request-cluster.sh --cluster-name CLUSTER_NAME --cluster-version 1.23 --weave-mode core

set -e

blnk=$(echo "$0" | sed 's/./ /g')
usage() {
  echo "Usage: $0 --cluster-name <CLUSTER_NAME> \\"
  echo "       $blnk [--cluster-version <CLUSTER_VERSION>] \\"
  echo "       $blnk [--weave-mode <enterprise|core|leaf|none> {default core}]"
  echo "       $blnk [--oss-tag <OSS_TAG> ]"
  echo "       $blnk [--weave-version <CHART_VERSION> ]"
  echo "       $blnk [--weave-branch <BRANCH_NAME> ]"
  echo "       $blnk [--enable-flagger]"
  echo "       $blnk [--enable-policies]"
  echo "       $blnk [--delete-after {default 15}]"
  echo "       $blnk [--team <TEAM_NAME>]"
  echo "       $blnk [-h|--help]"

  echo
  echo "  --cluster-name CLUSTER_NAME                -- Set cluster name"
  echo "  --cluster-version CLUSTER_VERSION          -- Set cluster version (default: 1.23)"
  echo "  --weave-mode <enterprise|core|leaf|none>   -- Select between installing WGE, WG-Core, leaf-cluster or not install any (enterprise|core|leaf|none)"
  echo "  --oss-tag OSS_TAG                          -- Select a specific image tag for OSS (those tags are pulled from the private feature image registry!)"
  echo "  --weave-version CHART_VERSION              -- Select a specific helm chart version (currently supports enterprise charts only)"
  echo "  --weave-branch BRANCH_NAME                 -- Select a specific git branch for installation (currently supports enterprise branches only)"
  echo "  --enable-flagger                           -- Flagger will be installed on the cluster (only available when --weave-mode=enterprise|leaf)"
  echo "  --enable-policies                          -- Default policies will be installed on the cluster (only available when --weave-mode=enterprise|leaf)"
  echo "  --delete-after                             -- Cluster will be auto deleted after this number of days (default: 15)"
  echo "  --team                                     -- Engineering team name"
  echo "  -h|--help                                  -- Print this help message and exit"
  exit 0
}

defaults(){
  export MAIN_BRANCH="main"
  export CLUSTER_VERSION="1.27"
  export WW_MODE="core"
  export ENABLE_FLAGGER="false"
  export ENABLE_POLICIES="false"
  export DELETE_AFTER="7"
  export SSL_CERTIFICATE_ARN="arn:aws:acm:eu-north-1:894516026745:certificate/5f8813f2-b630-4d0d-8c34-8fb68ec166ac"

  # OSS image repo:
  export OSS_REPO="ghcr.io/weaveworks/wego-app"
  export OSS_FB_REPO="docker.io/weaveworks/gitops-oss-prs"
  export OSS_LATEST_TAG="latest"
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
        if [ "${WW_MODE}" != "core" ] && [ "${WW_MODE}" != "enterprise" ] && [ "${WW_MODE}" != "leaf" ] && [ "${WW_MODE}" != "none" ]
        then
          echo -e "${ERROR} Invalid value of --weave-mode = ${WW_MODE}. Please select one of (enterprise, core, leaf or none)!"
          exit 1
        fi
        ;;
    --oss-tag)
        shift
        export OSS_TAG="$1"
        ;;
    --weave-version)
        shift
        export WEAVE_VERSION="$1"
        ;;
    --weave-branch)
        shift
        export WEAVE_BRANCH="$1"
        ;;
    --enable-flagger)
        export ENABLE_FLAGGER="true"
        ;;
    --enable-policies)
        export ENABLE_POLICIES="true"
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
    --team)
      shift
      export TEAM_NAME="$1"
      ;;
    -h|--help)
        usage;;
    *) usage;;
    esac
    shift
  done
}

source ${BASH_SOURCE%/*}/colors.sh
source ${BASH_SOURCE%/*}/common-functions.sh
# -------------------------------------------------------------------

defaults
flags "$@"
validateFlags

export PARENT_DIR=${BASH_SOURCE%/scripts*}
export CLUSTER_DIR=${PARENT_DIR}/clusters/${CLUSTER_NAME}

export EKS_CLUSTER_TEMPLATE=${PARENT_DIR}/eks-cluster.yaml-template
export EKS_CLUSTER_CONFIG_FILE=${PARENT_DIR}/clusters/${CLUSTER_NAME}-eksctl-cluster.yaml

export FLUX_KUSTOMIZATION_TEMPLATE=${PARENT_DIR}/flux-kustomization.yaml-template
export SECRETS_KUSTOMIZATION_TEMPLATE=${PARENT_DIR}/secrets-kustomization.yaml-template

export OIDC_ISSUER_URL=https://${CLUSTER_NAME}-dex.eng-sandbox.weave.works
export OIDC_REDIRECT_URL=https://${CLUSTER_NAME}.eng-sandbox.weave.works/oauth2/callback

CURRENT_BRANCH=$(git branch --show-current)
if [ $CURRENT_BRANCH != $MAIN_BRANCH ]
then
  echo -e "${ERROR} You're currently on ($CURRENT_BRANCH) branch. Please checkout to ($MAIN_BRANCH) branch and pull the latest."
  exit 1
else
  git pull origin $MAIN_BRANCH
fi

if [ -z $CLUSTER_NAME ]
then
  echo -e "${ERROR} No cluster name provided. Use '--cluster-name YOUR-CLUSTER' to set your cluster name."
  exit 1
fi

if [ -z $TEAM_NAME ]
then
  echo -e "${ERROR} --team argument is not provided. Use '--team YOUR-TEAM'."
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

# Copy eksctl config to cluster dir
echo "Copying eksctl config file..."
cp ${EKS_CLUSTER_TEMPLATE} ${EKS_CLUSTER_CONFIG_FILE}
sedi 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
sedi 's/${CLUSTER_VERSION}/'"${CLUSTER_VERSION}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
sedi 's/${BRANCH_NAME}/'"${BRANCH_NAME}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
sedi 's/${DELETE_AFTER}/'"${DELETE_AFTER}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
sedi 's/${TEAM}/'"${TEAM_NAME}"'/g' ${EKS_CLUSTER_CONFIG_FILE}
echo -e "${SUCCESS} '${EKS_CLUSTER_CONFIG_FILE}' is created successfully."

# Copy common apps to cluster dir
echo "Copying apps-common templates..."
cp -r ${PARENT_DIR}/apps/common/common-kustomization.yaml-template ${CLUSTER_DIR}/common-kustomization.yaml
sedi 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/common-kustomization.yaml
sedi 's+${SSL_CERTIFICATE_ARN}+'"${SSL_CERTIFICATE_ARN}"'+g' ${CLUSTER_DIR}/common-kustomization.yaml

# Copy flagger to cluster dir
if [ $ENABLE_FLAGGER == "true" ]
then
  cp -r ${PARENT_DIR}/apps/flagger/flagger-kustomization.yaml-template ${CLUSTER_DIR}/flagger-kustomization.yaml
fi

if [ $ENABLE_POLICIES == "true" ]
then
  cp -r ${PARENT_DIR}/policies/kustomization.yaml-template ${CLUSTER_DIR}/policies-kustomization.yaml
fi

# Copy apps to cluster dir
case $WW_MODE in
  core)
    USERNAME="wego-admin"
    PASSWORDHASH='$2a$10$6ErJr5BDz4xpS9QxtqeveuEl9.1bioDeRHFLNgqP31oTYNht3EC.a' # password

    echo "Copying WeaveGitops templates..."
    cp -r ${PARENT_DIR}/apps/gitops/gitops-kustomization.yaml-template ${CLUSTER_DIR}/gitops-kustomization.yaml
    sedi 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml

    sedi 's/${USERNAME}/'"${USERNAME}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml
    sedi 's/${PASSWORDHASH}/'"${PASSWORDHASH}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml
    if [ "${OSS_TAG}" ]
    then
      echo "This tag will be used: "${OSS_TAG}""
      sedi 's#${REPOSITORY}#'"${OSS_FB_REPO}"'#g' ${CLUSTER_DIR}/gitops-kustomization.yaml
      sedi 's/${TAG}/'"${OSS_TAG}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml
    else
      sedi 's#${REPOSITORY}#'"${OSS_REPO}"'#g' ${CLUSTER_DIR}/gitops-kustomization.yaml
      sedi 's/${TAG}/'"${OSS_LATEST_TAG}"'/g' ${CLUSTER_DIR}/gitops-kustomization.yaml
    fi
    ;;
  enterprise)
    echo "Copying WGE templates..."
    WGE_RELEASE_FILE="${PARENT_DIR}/apps/enterprise/enterprise-app/release.yaml"
    CHART_REPO="https://charts.dev.wkp.weave.works/releases/charts-v3"
    if [ "${WEAVE_BRANCH}" ]
    then
      CHART_REPO="https://charts.dev.wkp.weave.works/dev/branches/${WEAVE_BRANCH}"
    elif [ "${WEAVE_VERSION}" ]
    then
      sedi 's/version: .*/version: "'"${WEAVE_VERSION}"'"/g' ${WGE_RELEASE_FILE}
    fi
    cp -r ${PARENT_DIR}/apps/enterprise/enterprise-kustomization.yaml-template ${CLUSTER_DIR}/enterprise-kustomization.yaml
    sedi 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/enterprise-kustomization.yaml
    sedi 's/${BRANCH_NAME}/'"${BRANCH_NAME}"'/g' ${CLUSTER_DIR}/enterprise-kustomization.yaml
    sedi 's#${CHART_REPO}#'"${CHART_REPO}"'#g' ${CLUSTER_DIR}/enterprise-kustomization.yaml

    if [ $ENABLE_POLICIES == "true" ]
    then
      sedi 's/${APPS_KUSTOMIZATION}/'"enterprise"'/g' ${CLUSTER_DIR}/policies-kustomization.yaml
    fi
    ;;
  leaf)
    echo "Copying leaf cluster templates..."
    cp -r ${PARENT_DIR}/apps/enterprise-leaf/enterprise-leaf-kustomization.yaml-template ${CLUSTER_DIR}/enterprise-leaf-kustomization.yaml

    if [ $ENABLE_POLICIES == "true" ]
    then
      sedi 's/${APPS_KUSTOMIZATION}/'"enterprise-leaf"'/g' ${CLUSTER_DIR}/policies-kustomization.yaml
    fi
    ;;
  none)
    echo -e "${WARNING} Neither WG-Core nor WGE will be installed. Cluster will be provisioned with Flux only!"
    ;;
esac

# Copy secrets to cluster dir
cp ${SECRETS_KUSTOMIZATION_TEMPLATE} ${CLUSTER_DIR}/secrets-kustomization.yaml
BASE64_OIDC_ISSUER_URL=$(echo -n "${OIDC_ISSUER_URL}" | base64 | tr -d \\n)
BASE64_OIDC_REDIRECT_URL=$(echo -n "${OIDC_REDIRECT_URL}" | base64 | tr -d \\n)
sedi 's/${ISSUER_URL}/'"${BASE64_OIDC_ISSUER_URL}"'/g' ${CLUSTER_DIR}/secrets-kustomization.yaml
sedi 's/${REDIRECT_URL}/'"${BASE64_OIDC_REDIRECT_URL}"'/g' ${CLUSTER_DIR}/secrets-kustomization.yaml

# Setup SOPS decryption for flux kustomize-controller
mkdir -p ${CLUSTER_DIR}/flux-system
touch ${CLUSTER_DIR}/flux-system/gotk-components.yaml \
    ${CLUSTER_DIR}/flux-system/gotk-sync.yaml
cp ${FLUX_KUSTOMIZATION_TEMPLATE} ${CLUSTER_DIR}/flux-system/kustomization.yaml
sedi 's/${CLUSTER_NAME}/'"${CLUSTER_NAME}"'/g' ${CLUSTER_DIR}/flux-system/kustomization.yaml

echo -e "${SUCCESS} Cluster directory \"${CLUSTER_DIR}\" has been created"
echo -e "          Please, commit the files and push the branch to provision the cluster"
