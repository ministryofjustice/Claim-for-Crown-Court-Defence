#!/bin/sh
function _k8sjob() {
  usage="_k8sjob -- run job in the specified environment
  Usage: ./k8sjob.sh task environment
  Where:
    task [migrate|seed]
    environment [dev|staging|api-sandbox]"

  if [ $# -gt 2 ]
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
    dev | staging | api-sandbox)
      environment=$2
      ;;
    *)
      echo "$usage"
      return 0
      ;;
  esac

  context='live-1'
  version=$(git rev-parse $(git branch | grep \* | cut -d ' ' -f2))
  docker_registry=754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-get-paid/cccd
  docker_build_tag=app-${version}
  docker_image_tag=${docker_registry}:${docker_build_tag}

  echo "Delete previous db-$task jobs..."
  kubectl delete job db-$task

  
  echo "--------------------------------------------------"
  echo "Task: $task"
  echo "Job: kubernetes_deploy/jobs/${task}.yaml"
  echo "context: $context"
  echo "Environment: $environment"
  echo "Docker image: $docker_image_tag"
  echo "--------------------------------------------------"
  kubectl set image -f kubernetes_deploy/jobs/${task}.yaml cccd-app=${docker_image_tag} --local -o yaml | kubectl apply --context ${context} -n cccd-${environment} -f -
  job_pod=$(kubectl get pods --selector=job-name=db-${task} --output=jsonpath='{.items[0].metadata.name}')
  echo "To tail issue command:
    kubectl logs --follow ${job_pod}
  Attempting tail now....."
  kubectl wait pods/${job_pod} --for condition=available --timeout=10s
  kubectl logs --follow ${job_pod}

}

_k8sjob $@
