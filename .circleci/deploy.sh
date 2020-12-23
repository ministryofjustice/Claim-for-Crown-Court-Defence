#!/bin/sh

function _circleci_deploy() {
  usage="deploy -- deploy image from current commit to an environment
  Usage: $0 environment
  Where:
    environment [dev|staging|api-sandbox|production]
  Example:
    # deploy image for current circleCI commit to dev
    deploy.sh dev
    "

  # exit when any command fails
  set -e
  trap 'echo command at lineno $LINENO completed with exit code $?.' EXIT

  if [[ -z "${ECR_ENDPOINT}" ]] || \
      [[ -z "${GIT_CRYPT_KEY}" ]] || \
      [[ -z "${AWS_DEFAULT_REGION}" ]] || \
      [[ -z "${GITHUB_TEAM_NAME_SLUG}" ]] || \
      [[ -z "${REPO_NAME}" ]] || \
      [[ -z "${CIRCLE_SHA1}" ]]
  then
    echo "Missing environment vars: only run this via circleCI with all relevant environment variables"
    return 1
  fi

  if [[ $# -gt 1 ]]
  then
    echo "$usage"
    return 1
  fi

  # Cloud platforms circle ci solution does not handle hyphenated names
  case "$1" in
    dev | staging | production)
      environment=$1
      cp_context=$environment
      ;;
    api-sandbox)
      environment=$1
      cp_context=sandbox
      ;;
    dev-lgfs)
      environment=$1
      cp_context=$(echo $1 | tr -d '-')
      ;;
    *)
      echo "$usage"
      return 1
      ;;
  esac

  # Cloud platform required setup
  aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_ENDPOINT}
  setup-kube-auth
  kubectl config use-context ${cp_context}

  echo "${GIT_CRYPT_KEY}" | base64 -d > git-crypt.key
  git-crypt unlock git-crypt.key

  # apply
  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mCommit: $CIRCLE_SHA1\e[0m\n"
  printf "\e[33mBranch: $CIRCLE_BRANCH\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"

  docker_image_tag=${ECR_ENDPOINT}/${GITHUB_TEAM_NAME_SLUG}/${REPO_NAME}:app-${CIRCLE_SHA1}

  # apply common config
  kubectl apply -f kubernetes_deploy/${environment}/secrets.yaml
  kubectl apply -f kubernetes_deploy/${environment}/app-config.yaml

  # apply new image
  kubectl set image -f kubernetes_deploy/${environment}/deployment.yaml cccd-app=${docker_image_tag} --local -o yaml | kubectl apply -f -
  kubectl set image -f kubernetes_deploy/${environment}/deployment-worker.yaml cccd-worker=${docker_image_tag} --local -o yaml | kubectl apply -f -
  kubectl set image -f kubernetes_deploy/cron_jobs/archive_stale.yaml cronjob-worker=${docker_image_tag} --local -o yaml | kubectl apply -f -

  # apply non-image specific config
  kubectl apply \
  -f kubernetes_deploy/${environment}/service.yaml \
  -f kubernetes_deploy/${environment}/ingress.yaml

  # only needed in one environment and cccd-dev has credentials
  if [[ ${environment} == 'dev' ]]; then
    kubectl apply -f kubernetes_deploy/cron_jobs/clean_ecr.yaml
  fi

  kubectl annotate deployments/claim-for-crown-court-defence kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"
  kubectl annotate deployments/claim-for-crown-court-defence-worker kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"

  # wait for rollout to succeed or fail/timeout
  kubectl rollout status deployments/claim-for-crown-court-defence
  kubectl rollout status deployments/claim-for-crown-court-defence-worker
}

_circleci_deploy $@
