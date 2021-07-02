#!/bin/sh
function _cronjob() {
  usage="cronjob -- apply job in the specified environment
  Usage: cronjob job environment [branch]
  Where:
    job [archive_stale|clean_ecr|vacuum_db|submitted_claims_report]
    environment [dev|dev-lgfs|staging|api-sandbox|production]
    branch [<branchname>-latest|commit-sha]

  Example:
    # apply changes to clean_ecr cronjob
    cronjob.sh clean_ecr

    # apply changes to archive_stale job in dev AND use pod based on latest master
    cronjob.sh archive_stale dev latest

    # apply changes to archive_stale job in dev AND use pod based on latest for branch
    cronjob.sh archive_stale staging kubernetes-latest

    # apply changes to archive_stale job in dev AND use pod based on <commit-sha>
    cronjob.sh archive_stale dev <commit-sha>
    "

  if [ $# -gt 3 ]
  then
    echo "$usage"
    return 0
  fi

  case "$1" in
    archive_stale | vacuum_db | submitted_claims_report)
      job=$1
      ;;
    clean_ecr)
      echo "Setting namespace to dev as only this has the ECR secret..."
      kubectl config set-context --current --namespace=cccd-dev
      kubectl apply -f kubernetes_deploy/cron_jobs/$1.yaml
      return $?
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  case "$2" in
    dev | dev-lgfs | staging | api-sandbox | production)
      environment=$2
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  if [ -z "$3" ]
  then
    current_branch=$(git branch | grep \* | cut -d ' ' -f2)
    current_version=$(git rev-parse $current_branch)
  else
    current_version=$3
  fi

  context=$(kubectl config current-context)
  component=app
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd
  docker_image_tag=${docker_registry}:${component}-${current_version}

  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mCronJob file: ${job}.yaml\e[0m\n"
  printf "\e[33mContext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: $docker_image_tag\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"

  kubectl config set-context --current --namespace=cccd-${environment}
  kubectl set image -f kubernetes_deploy/cron_jobs/${job}.yaml cronjob-worker=${docker_image_tag} --local -o yaml | kubectl apply -f -

}

_cronjob $@
