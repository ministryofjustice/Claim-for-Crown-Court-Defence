#!/bin/sh

function _circleci_deploy() {
  usage="deploy -- deploy image from current commit to an environment
  Usage: $0 environment
  Where:
    environment [dev|dev-lgfs|staging|api-sandbox|production]
  Example:
    # deploy image for current circleCI commit to live clusters cccd-dev namespace
    deploy.sh dev
    "

  # exit when any command fails
  set -e
  trap 'echo command at lineno $LINENO completed with exit code $?.' EXIT

  if [[ -z "${ECR_ENDPOINT}" ]] || \
      [[ -z "${AWS_DEFAULT_REGION}" ]] || \
      [[ -z "${GITHUB_TEAM_NAME_SLUG}" ]] || \
      [[ -z "${REPO_NAME}" ]] || \
      [[ -z "${K8S_CLUSTER_CERT}" ]] || \
      [[ -z "${K8S_CLUSTER_NAME}" ]] || \
      [[ -z "${K8S_CLUSTER_URL}" ]] || \
      [[ -z "${K8S_TOKEN}" ]] || \
      [[ -z "${K8S_NAMESPACE}" ]] || \
      [[ -z "${CIRCLE_SHA1}" ]]
  then
    echo "Missing environment vars: only run this via circleCI with all relevant environment variables"
    return 1
  fi

  if [[ $# -ne 1 ]]
  then
    echo "$usage"
    return 1
  fi

  cluster_dir='live'

  case "$1" in
    dev | dev-lgfs | api-sandbox | staging | production)
      environment=$1
      ;;
    *)
      echo "$usage"
      return 1
      ;;
  esac

  # Login to ECR to pull docker image
  aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_ENDPOINT}

  # Authenticate with k8s cluster
  # see cirlcleci shared contexts, https://circleci.com/docs/2.0/contexts/
  echo -n ${K8S_CLUSTER_CERT} | base64 -d > ./ca.crt
  kubectl config set-cluster ${K8S_CLUSTER_NAME} --certificate-authority=./ca.crt --server=${K8S_CLUSTER_URL}
  kubectl config set-credentials circleci --token=$(echo -n ${K8S_TOKEN} | base64 -d)
  kubectl config set-context ${K8S_CLUSTER_NAME} --cluster=${K8S_CLUSTER_NAME} --user=circleci --namespace=${K8S_NAMESPACE}
  kubectl config use-context ${K8S_CLUSTER_NAME}
  kubectl --namespace=${K8S_NAMESPACE} get pods

  # apply
  printf "\e[33m--------------------------------------------------\e[0m\n"
  printf "\e[33mEnvironment: $environment\e[0m\n"
  printf "\e[33mCommit: $CIRCLE_SHA1\e[0m\n"
  printf "\e[33mBranch: $CIRCLE_BRANCH\e[0m\n"
  printf "\e[33m--------------------------------------------------\e[0m\n"

  docker_image_tag=${ECR_ENDPOINT}/${GITHUB_TEAM_NAME_SLUG}/${REPO_NAME}:app-${CIRCLE_SHA1}

  # apply common config
  kubectl apply -f .k8s/${cluster_dir}/${environment}/app-config.yaml

  # apply new image
  kubectl set image -f .k8s/${cluster_dir}/${environment}/deployment.yaml cccd-app=${docker_image_tag} --local -o yaml | kubectl apply -f -
  kubectl set image -f .k8s/${cluster_dir}/${environment}/deployment-worker.yaml cccd-worker=${docker_image_tag} --local -o yaml | kubectl apply -f -

  # apply changes that always use app-latest tagged images
  kubectl apply \
    -f .k8s/${cluster_dir}/cron_jobs/archive_stale.yaml \
    -f .k8s/${cluster_dir}/cron_jobs/vacuum_db.yaml

  # get ip addresses for allowlists
  LAA_IPS=$(curl -s https://raw.githubusercontent.com/ministryofjustice/laa-ip-allowlist/main/cidrs.txt | tr -d ' ' | tr '\n' ',')
  PINGDOM_IPS=$(curl -s https://my.pingdom.com/probes/ipv4 | tr -d ' ' | tr '\n' ',')
  COMBINED_IPS="${PINGDOM_IPS}${LAA_IPS}"

  # populate ingress file with ip addresses
  sed -i -e "s#<allowlist-populated-by-deploy-script>#${COMBINED_IPS}#" .k8s/${cluster_dir}/${environment}/ingress.yaml;

  # apply non-image specific config
  kubectl apply \
  -f .k8s/${cluster_dir}/${environment}/service.yaml \
  -f .k8s/${cluster_dir}/${environment}/ingress.yaml

  # apply rules for prometheus alerts
  kubectl apply -f .k8s/${cluster_dir}/${environment}/prometheus-custom-rules.yaml

  kubectl annotate deployments/claim-for-crown-court-defence kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"
  kubectl annotate deployments/claim-for-crown-court-defence-worker kubernetes.io/change-cause="$(date +%Y-%m-%dT%H:%M:%S%z) - deploying: $docker_image_tag via CircleCI"

  # wait for rollout to succeed or fail/timeout
  kubectl rollout status deployments/claim-for-crown-court-defence
  kubectl rollout status deployments/claim-for-crown-court-defence-worker
}

_circleci_deploy $@
