#!/bin/sh
function _k8sbuild() {
  usage="k8build -- build, tag and push image to ecr
  Usage: ./k8sbuild.sh"

  region='eu-west-2'
  context='live-1'
  aws_profile='ecr-live1'

  team_name=laa-get-paid
  repo_name=cccd
  docker_endpoint=754256621582.dkr.ecr.eu-west-2.amazonaws.com
  docker_registry=${docker_endpoint}/${team_name}/${repo_name}

  component=app
  version=$(git rev-parse $(git branch | grep \* | cut -d ' ' -f2))
  docker_build_tag=${component}-${version}
  docker_registry_tag=${docker_registry}:${docker_build_tag}

  echo '------------------------------------------------------------------------'
  echo "Build tag: $docker_build_tag"
  echo "Registry tag: $docker_registry_tag"
  echo '------------------------------------------------------------------------'
  printf '\e[33mDocker login to registry (ECR)...\e[0m\n'
  $(aws ecr --profile "$aws_profile" get-login --no-include-email --region "$region")

  printf '\e[33mBuilding app container image locally...\e[0m\n'
  docker build \
          --build-arg VERSION_NUMBER=$docker_registry_tag \
          --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
          --build-arg COMMIT_ID=$version \
          --build-arg BUILD_TAG=$docker_build_tag \
          --pull \
          --tag ${docker_registry_tag} \
          --file docker/Dockerfile .

  printf '\e[33m[Pushing app container image to ECR...\e[0m\n'
  docker push ${docker_registry_tag}
  printf '\e[33mPushed app container image to ECR...\e[0m\n'

}

_k8sbuild $@
