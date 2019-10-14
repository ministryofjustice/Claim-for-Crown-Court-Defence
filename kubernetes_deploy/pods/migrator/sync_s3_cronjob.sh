#!/bin/sh
function _sync_s3() {
  usage="sync_s3 -- apply scheduled sync s3 job in the specified environment
  Usage: sync_s3_cronjob environment
  Where:
    environment [dev|staging|api-sandbox|production]

  Example:
    # apply changes to clean_ecr cronjob
    sync_s3_cronjob.sh dev
    "

  if [[ $# -ne 1 ]]
  then
    echo "$usage"
    return 0
  fi

  context='live-1'

  case "$1" in
    dev | staging | api-sandbox | production)
      environment=$1
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  cronjob_file=kubernetes_deploy/pods/migrator/sync_s3_cronjob.yaml
  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mJob: ${cronjob_file}\e[0m\n"
  printf "\e[33mContext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: see $cronjob_file\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"
  kubectl apply --context ${context} -n cccd-${environment} -f ${cronjob_file}

}

_sync_s3 $@
