#!/bin/sh
function _job() {
  usage="job -- run job in the specified environment
  Usage: .k8s/live/bin/job task environment
  Where:
    task [migrate|seed|dump]
    environment [dev|dev-lgfs|staging|api-sandbox|production]
    branch [<branchname>-latest|commit-sha]
    "

  if [ $# -gt 3 ]
  then
    echo "$usage"
    return 0
  fi

  case "$1" in
    migrate | seed | dump)
      task=$1
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

  context='live'
  component=app
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd
  docker_image_tag=${docker_registry}:${component}-${current_version}
  job_name=db-$task

  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mTask: $task\e[0m\n"
  printf "\e[33mJob name: $job_name\e[0m\n"
  printf "\e[33mJob config: .k8s/${context}/jobs/${task}.yaml\e[0m\n"
  printf "\e[33mcontext: $context\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mDocker image: $docker_image_tag\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"

  kubectl config set-context ${context} --namespace=cccd-${environment}
  kubectl config use-context ${context}

  kubectl delete job $job_name

  # apply common config
  kubectl apply -f .k8s/${context}/${environment}/app-config.yaml

  # apply image
  kubectl set image -f .k8s/${context}/jobs/${task}.yaml cccd-job=${docker_image_tag} --local -o yaml | kubectl apply -f -

  # wait for job pod container to be ready before tailing logs
  kubectl wait --for=condition=ContainersReady --timeout=240s pod --selector job-name=$job_name
  kubectl logs --follow job/$job_name

}

_job $@
