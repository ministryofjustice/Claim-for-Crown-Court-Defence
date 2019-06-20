#!/bin/sh
function _k8sdeploy() {
  usage="k8sdeploy -- deploy image from current commit to an environment
  Usage: ./k8sdeploy.sh environment
  Where:
    environment [dev|staging|api-sandbox]"

  if [ $# -gt 1 ]
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

  context='live-1'
  component=app
  current_branch=$(git branch | grep \* | cut -d ' ' -f2)
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd

  # get latest tag for branch
  case $current_branch in
    master)
      docker_image_tag=${docker_registry}:${component}-latest
      ;;
    *)
      docker_image_tag=${docker_registry}:${component}-${current_branch}-latest
      ;;
  esac

  kubectl config set-context ${context} --namespace=cccd-${environment}
  kubectl config use-context ${context}

  echo "--------------------------------------------------"
  echo "Context: $context"
  echo "Environment: $environment"
  echo "Current branch: $current_branch"
  echo "Docker image: $docker_image_tag"
  echo "--------------------------------------------------"

  kubectl set image -f kubectl_deploy/${environment}/deployment.yaml cccd-app=${docker_image_tag} --local -o yaml | kubectl apply -f -
  kubectl apply \
    -f kubectl_deploy/${environment}/service.yaml \
    -f kubectl_deploy/${environment}/ingress.yaml

}

_k8sdeploy $@
