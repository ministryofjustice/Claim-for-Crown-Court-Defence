#!/bin/sh
function _job() {
  usage="job -- run job in the specified environment
  Usage: kubernetes_deploy/bin/job task environment
  Where:
    task [migrate|seed]
    environment [dev|staging|api-sandbox|production]
    branch [<branchname>-latest|commit-sha]
    "

  if [ $# -gt 3 ]
  then
    echo "$usage"
    return 0
  fi

  case "$1" in
    migrate | seed)
      task=$1
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  case "$2" in
    dev | staging | api-sandbox | production)
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

  context='live-1'
  component=app
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd
  docker_image_tag=${docker_registry}:${component}-${current_version}

  echo "Delete previous db-$task jobs..."
  kubectl delete job db-$task

  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mTask: $task\e[0m\n"
  printf "\e[33mJob: kubernetes_deploy/jobs/${task}.yaml\e[0m\n"
  printf "\e[33mcontext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: $docker_image_tag\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"
  kubectl set image -f kubernetes_deploy/jobs/${task}.yaml cccd-app=${docker_image_tag} --local -o yaml | kubectl apply --context ${context} -n cccd-${environment} -f -

  # wait for completion/timeout and output logs
  kubectl wait --for=condition=complete --timeout=120s job/db-${task}
  job_pod=$(kubectl get pods --selector=job-name=db-${task} --output=jsonpath='{.items[0].metadata.name}')
  kubectl logs --follow ${job_pod}

}

_job $@
