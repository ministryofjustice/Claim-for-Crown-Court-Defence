#!/bin/sh
function _deploy() {
  usage="deploy -- deploy image from current commit to an environment
  Usage: kubernetes_deploy/bin/deploy environment [image-tag]
  Where:
    environment [dev|staging|api-sandbox|production]
    [image_tag] any valid ECR image tag for app
  Example:
    # deploy image for current commit to dev
    deploy.sh dev

    # deploy latest image of master to dev
    deploy.sh dev latest

    # deploy latest branch image to dev
    deploy.sh dev <branch-name>-latest

    # deploy specific image (based on commit sha)
    deploy.sh dev <commit-sha>
    "

  if [ $# -gt 2 ]
  then
    echo "$usage"
    return 0
  fi

  case "$1" in
    dev | dev-lgfs | staging | api-sandbox | production)
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

  kubectl config set-context ${context} --namespace=cccd-${environment}
  kubectl config use-context ${context}

  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mContext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: $docker_image_tag\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"

  # TODO: check if image exists and if not offer to build or abort

  # apply image specific config
  kubectl apply -f kubernetes_deploy/${environment}/secrets.yaml
  kubectl set image -f kubernetes_deploy/${environment}/deployment.yaml cccd-app=${docker_image_tag} --local --output yaml | kubectl apply -f -
  kubectl set image -f kubernetes_deploy/cron_jobs/archive_stale.yaml cronjob-worker=${docker_image_tag} --local --output yaml | kubectl apply -f -

  # apply non-image specific config
  kubectl apply \
    -f kubernetes_deploy/${environment}/service.yaml \
    -f kubernetes_deploy/${environment}/ingress.yaml

  # only needed in one environment and cccd-dev has credentials
  if [[ ${environment} == 'dev' ]]; then
    kubectl apply -f kubernetes_deploy/cron_jobs/clean_ecr.yaml
  fi

  kubectl annotate deployments/claim-for-crown-court-defence kubernetes.io/change-cause="$(date) - deploying: $docker_image_tag via local machine"

  # Forcibly restart the app regardless of whether
  # there are changes to apply new secrets, at least.
  # - requires kubectl verion 1.15+
  #
  kubectl rollout restart deployments/claim-for-crown-court-defence
}

_deploy $@
