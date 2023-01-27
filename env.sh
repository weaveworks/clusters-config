#!/usr/bin/env bash
# Set up environment
# Dependencies:
# - AWS CLI v2
# - gsts: read the docs, needs config. I assume using a profile named `sts` for this script via .envrc
# This script must be sourced, not run directly

_awsCliV2_docs=(
  "https://aws.amazon.com/cli/"
  "https://www.notion.so/weaveworks/Accessing-AWS-Resources-600faa584fec4c6ba5b0f2ef27be309e"
)
_direnv_docs=(
  "https://direnv.net/"
)
_eksctl_docs=(
  "https://eksctl.io/introduction/#installation"
)
_gsts_docs=(
  "https://github.com/ruimarinho/gsts"
)
_precommit_docs=(
  "https://pre-commit.com/"
)

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ ${sourced} != "1" ]]; then
  printf "Don't run %s, source it with \"source %s\"\n" "${0}" "${0}" >&2
  exit 63
fi

# Test for presence of AWS CLI v2
if ! command -v aws >/dev/null; then
  echo "If you intend to manage clusters, please install the AWS CLI v2:"
  printf "%s\n" "${_awsCliV2_docs[@]}"
  return 64
fi

# Test for presence of direnv
if ! command -v direnv >/dev/null; then
  echo "If you intend to manage clusters, please install direnv:"
  printf "%s\n" "${_direnv_docs[@]}"
  return 64
fi

# Test for presence of eksctl
if ! command -v eksctl >/dev/null; then
  echo "If you intend to manage clusters, please install eksctl:"
  printf "%s\n" "${_eksctl_docs[@]}"
  return 64
fi

# Test for presence of gsts
if ! command -v gsts >/dev/null; then
  echo "If you intend to manage clusters, please install gsts:"
  printf "%s\n" "${_gsts_docs[@]}"
  return 64
fi

# Test for presence of precommit
if ! command -v pre-commit >/dev/null; then
  echo "If you intend to manage clusters, please install precommit:"
  printf "%s\n" "${_precommit_docs[@]}"
  return 64
fi

_test_gsts_username() {
  if [ -z "${GOOGLE_USERNAME}" ]; then
    printf "%s\n" "Please set GOOGLE_USERNAME to your work email address"
    return 65
  fi
}

_test_gsts_username || return 67

# gsts is a common alias for ZSH users, particularly those using oh-my-zsh. Prefix with `/usr/bin/env` # to avoid this
_gsts_auth() {
  /usr/bin/env gsts --aws-role-arn "${AWS_ROLE_ARN}" --force || return 68
}

_gsts_auth || return 70

printf "Environment configured, authenticated to AWS as %s.\n" "${AWS_ROLE_ARN}"
