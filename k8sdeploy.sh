#!/bin/sh
function _k8sdeploy() {
  usage="k8sdeploy -- deploy image from current commit to an environment
  Usage: ./k8sdeploy.sh environment
  Where:
    environment [dev|staging]"

  if [ $# -gt 2 ]
  then
    echo "$usage"
    return 0
  fi

  case "$1" in
    dev | staging)
      environment=$1
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  context='live-1'
  version=$(git rev-parse $(git branch | grep \* | cut -d ' ' -f2))
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd
  docker_tag=app-${version}
  docker_image_tag=${docker_registry}:${docker_tag}

  echo "Deploying $docker_image_tag to $environment on cluster $context"
  kubectl set image -f kubectl_deploy/${environment}/deployment.yaml cccd-app=${docker_image_tag} --local -o yaml | kubectl apply -n cccd-${environment} --context ${context} -f -
  echo "Applying service..."
  kubectl apply -n cccd-${environment} --context ${context} -f kubectl_deploy/${environment}/service.yaml
  echo "Applying ingress..."
  kubectl apply -n cccd-${environment} --context ${context} -f kubectl_deploy/${environment}/ingress.yaml

}

_k8sdeploy $@
