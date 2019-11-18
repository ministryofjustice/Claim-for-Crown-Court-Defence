#!/bin/sh

function _circleci_build() {
  usage="build -- build, tag and push app image for current CircleCI commit to ecr
  Where:
    workflow [app|admin-app]
  Usage: build"

  if [[ -z "${ECR_ENDPOINT}" ]] || \
      [[ -z "${AWS_DEFAULT_REGION}" ]] || \
      [[ -z "${GITHUB_TEAM_NAME_SLUG}" ]] || \
      [[ -z "${REPO_NAME}" ]] || \
      [[ -z "${CIRCLE_BRANCH}" ]] || \
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
    app | admin-app)
      workflow=$1
      circle_workflow=$workflow
      ;;
    *)
      echo "$usage"
      return 1
      ;;
  esac

  # build
  docker_registry_tag="${ECR_ENDPOINT}/${GITHUB_TEAM_NAME_SLUG}/${REPO_NAME}:${circle_workflow}-${CIRCLE_SHA1}"

  printf "\e[33m------------------------------------------------------------------------\e[0m\n"
  printf "\e[33mBranch: $CIRCLE_BRANCH\e[0m\n"
  printf "\e[33mRegistry tag: $docker_registry_tag\e[0m\n"
  printf "\e[33m------------------------------------------------------------------------\e[0m\n"

  $(aws ecr get-login --region ${AWS_DEFAULT_REGION} --no-include-email)

  docker build \
    --build-arg VERSION_NUMBER="NOT USED ANYMORE" \
    --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
    --build-arg COMMIT_ID=${CIRCLE_SHA1} \
    --build-arg BUILD_TAG="app-${CIRCLE_SHA1}" \
    --build-arg APP_BRANCH=${CIRCLE_BRANCH} \
    --build-arg LIVE1_DB_TASK=migrate \
    --pull \
    --tag $docker_registry_tag \
    --file docker/Dockerfile .

  # push
  docker push $docker_registry_tag

  if [ "${CIRCLE_BRANCH}" == "master" ]; then
    docker_registry_latest_tag="${ECR_ENDPOINT}/${GITHUB_TEAM_NAME_SLUG}/${REPO_NAME}:${circle_workflow}-latest"
    docker tag $docker_registry_tag $docker_registry_latest_tag
    docker push $docker_registry_latest_tag
  fi
}

_circleci_build $@
