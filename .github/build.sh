#!/bin/sh

set -eu

if [ -z "${ECR_REGISTRY_URL:-}" ] || \
  [ -z "${ECR_REPOSITORY:-}" ] || \
  [ -z "${ECR_REGION:-}" ] || \
  [ -z "${GITHUB_REF_NAME:-}" ] || \
  [ -z "${GITHUB_SHA:-}" ]
then
  echo "Missing environment vars required to build and push the image"
  exit 1
fi

docker_registry="${ECR_REGISTRY_URL}/${ECR_REPOSITORY}"
docker_registry_tag="${docker_registry}:app-${GITHUB_SHA}"

printf '\033[33m------------------------------------------------------------------------\033[0m\n'
printf '\033[33mBranch: %s\033[0m\n' "${GITHUB_REF_NAME}"
printf '\033[33mRegistry tag: %s\033[0m\n' "${docker_registry_tag}"
printf '\033[33m------------------------------------------------------------------------\033[0m\n'

docker build \
  --build-arg VERSION_NUMBER="NOT USED ANYMORE" \
  --build-arg BUILD_DATE="$(date +%Y-%m-%dT%H:%M:%S%z)" \
  --build-arg COMMIT_ID="${GITHUB_SHA}" \
  --build-arg BUILD_TAG="app-${GITHUB_SHA}" \
  --build-arg APP_BRANCH="${GITHUB_REF_NAME}" \
  --build-arg LIVE1_DB_TASK=migrate \
  --pull \
  --tag "${docker_registry_tag}" \
  --file docker/Dockerfile .

docker push "${docker_registry_tag}"

if [ "${GITHUB_REF_NAME}" = "main" ]; then
  docker_registry_current_production_tag="${docker_registry}:app-latest"
  docker tag "${docker_registry_tag}" "${docker_registry_current_production_tag}"
  docker push "${docker_registry_current_production_tag}"

  docker_registry_latest_tag="${docker_registry}:app-latest-$(date +%Y%m%d%H%M%S)"
else
  branch_name=$(printf '%s' "${GITHUB_REF_NAME}" | tr '/\\' '-')
  docker_registry_latest_tag="${docker_registry}:app-${branch_name}-latest"
fi

docker tag "${docker_registry_tag}" "${docker_registry_latest_tag}"
docker push "${docker_registry_latest_tag}"