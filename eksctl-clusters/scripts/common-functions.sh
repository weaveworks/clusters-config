#! /bin/bash

set -e

sedi(){
  case $(uname -s) in
      *[Dd]arwin* | *BSD* ) sed -i '' "$@";;
      *) sed -i "$@";;
  esac
}

validateFlags(){
  # Use --oss-tag with --weave-mode gitops only!
  if [ ${OSS_TAG} ] && [ "${WW_MODE}" != "core" ]
  then
    echo -e "${ERROR} Can not use [--oss-tag] with --weave-mode "${WW_MODE}". It shoud be used only with [--weave-mode gitops]"
  fi

  # Prevent using --weave-version and --weave-branch together!
  if [ $WEAVE_VERSION ] && [ $WEAVE_BRANCH ]
  then
    echo -e "${ERROR} --weave-version cannot be used with --weave-branch. You should only use one!"
    exit 1
  fi

  # Prevent using --weave-version or --weave-branch with modes other than enterprise!
  if [ $WEAVE_VERSION ] || [ $WEAVE_BRANCH ]
  then
    if [ "${WW_MODE}" != "enterprise" ]
    then
      echo -e "${ERROR} [--weave-version|--weave-branch] are supported only with enterprise mode!"
      exit 1
    fi
  fi

  # Using --enable-flager with --weave-mode enterprise or leaf only!
  if [ "$ENABLE_FLAGGER" == "true" ] && ( [ "${WW_MODE}" != "enterprise" ] && [ "${WW_MODE}" != "leaf" ] )
  then
    echo -e "${ERROR} --enable-flagger can only be used with --weave-mode=enterprise|leaf."
    exit 1
  fi

  # Using --enable-policies with --weave-mode enterprise or leaf only!
  if [ "$ENABLE_POLICIES" == "true" ] && ( [ "${WW_MODE}" != "enterprise" ] && [ "${WW_MODE}" != "leaf" ] )
  then
    echo -e "${ERROR} --enable-policies can only be used with --weave-mode=enterprise|leaf."
    exit 1
  fi
}
