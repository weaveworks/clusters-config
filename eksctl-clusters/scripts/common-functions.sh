#! /bin/bash

set -e

sedi(){
  case $(uname -s) in
      *[Dd]arwin* | *BSD* ) sed -i '' "$@";;
      *) sed -i "$@";;
  esac
}

validateFlags(){
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
}
