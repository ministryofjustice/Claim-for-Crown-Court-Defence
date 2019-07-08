#!/bin/sh
function _k8sdeploy() {
  usage="k8sdeploy -- deploy image from current commit to an environment
  Usage: ./k8sdeploy.sh environment [image-tag]
  Where:
    environment [dev|staging|api-sandbox]
    [image_tag] any valid ECR image tag for app
  Example:
    # deploy image for current commit to dev
    ./k8sdeploy.sh dev

    # deploy latest image of master to dev
    ./k8sdeploy.sh dev latest

    # deploy latest branch image to dev
    ./k8sdeploy.sh dev <branch-name>-latest

    # deploy specific image (based on commit sha)
    ./k8sdeploy.sh dev <commit-sha>
    "

  if [ $# -gt 2 ]
  then
    echo "$usage"
    return 0
  fi

  case "$1" in
    dev | staging | api-sandbox)
      environment=$1
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  if [ -z "$2" ]
  then
    current_branch=$(git branch | grep \* | cut -d ' ' -f2)
    current_version=$(git rev-parse $current_branch)
  else
    current_version=$2
  fi

  context='live-1'
  component=app
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd
  docker_image_tag=${docker_registry}:${component}-${current_version}

  # get latest tag for branch
  # DOES NOT WORK FOR JUST A DEPLOY WITH NO CHANGES TO deployment.yaml
  # case $current_branch in
  #   master)
  #     docker_image_tag=${docker_registry}:${component}-latest
  #     ;;
  #   *)
  #     docker_image_tag=${docker_registry}:${component}-${current_branch}-latest
  #     ;;
  # esac

  kubectl config set-context ${context} --namespace=cccd-${environment}
  kubectl config use-context ${context}

  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mContext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: $docker_image_tag\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"

  # TODO: check if image exists and if not offer to build or abort

  # apply image specific config
  kubectl set image -f kubernetes_deploy/${environment}/deployment.yaml cccd-app=${docker_image_tag} --local --output yaml | kubectl apply -f -
  kubectl set image -f kubernetes_deploy/cron_jobs/archive_stale.yaml cronjob-worker=${docker_image_tag} --local --output yaml | kubectl apply -f -

  # apply non-image specific config
  kubectl apply \
    -f kubernetes_deploy/${environment}/service.yaml \
    -f kubernetes_deploy/${environment}/ingress.yaml \
    -f kubernetes_deploy/${environment}/secrets.yaml \
    -f kubernetes_deploy/cron_jobs/clean_ecr.yaml

  # Forcibly restart the app regardless of whether
  # there are changes to apply new secrets, at least.
  # - requires kubectl verion 1.15+
  #
  kubectl annotate deployments/claim-for-crown-court-defence kubernetes.io/change-cause="$(date) - deploying: $docker_image_tag"
  kubectl rollout restart deployments/claim-for-crown-court-defence

}

_k8sdeploy $@
