#!/bin/sh
function _deploy_migrator() {
  usage="deploy -- deploy template-deploy-migrator pod
  into a namespace.
  Usage: kubernetes_deploy/pods/migrator/deploy.sh environment
  Where:
    environment [dev|staging|api-sandbox|production]
  "

  if [ $# -gt 1 ]
  then
    echo "$usage"
    return 0
  fi


  case "$1" in
    dev | staging | api-sandbox | production)
      environment=$1
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  context='live-1'
  component=migrator
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd
  docker_image_tag=${docker_registry}:${component}-latest

  echo "Deleting previous pod..."
  kubectl --context ${context} -n cccd-${environment} delete pod cccd-template-deploy-migrator

  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mJob: kubernetes_deploy/pods/migrator/pod.yaml\e[0m\n"
  printf "\e[33mcontext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: $docker_image_tag\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"
  kubectl apply --context ${context} -n cccd-${environment} -f kubernetes_deploy/pods/migrator/${environment}/secrets.yaml
  kubectl apply --context ${context} -n cccd-${environment} -f kubernetes_deploy/pods/migrator/pod.yaml
}

_deploy_migrator $@
