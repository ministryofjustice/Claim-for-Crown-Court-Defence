#!/bin/sh
function _k8sbuild() {
  usage="k8build -- build, tag and push image to ecr
  Usage: ./k8sbuild.sh"

  region='eu-west-2'
  context='live-1'
  aws_profile='ecr-live1'

  team_name=laa-get-paid
  repo_name=cccd
  ecr_container=754256621582.dkr.ecr.eu-west-2.amazonaws.com
  docker_registry=${ecr_container}/${team_name}/${repo_name}

  component=app
  version=$(git rev-parse $(git branch | grep \* | cut -d ' ' -f2))
  docker_build_tag=${component}-${version}
  docker_tag=${team_name}/${repo_name}:${component}

  docker_image=${docker_registry}:${docker_build_tag}
  echo '------------------------------------------------------------------------'
  echo "Image: $docker_image"
  echo "Build tag: $docker_build_tag"
  echo "ECR tag: $docker_tag"
  echo '------------------------------------------------------------------------'

  $(aws ecr --profile "$aws_profile" get-login --no-include-email --region "$region")
  docker build \
          --build-arg VERSION_NUMBER=$docker_image \
          --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
          --build-arg COMMIT_ID=$version \
          --build-arg BUILD_TAG=$docker_build_tag \
          -t ${docker_tag} -f docker/Dockerfile .
  docker tag ${docker_tag} ${docker_image}
  docker push ${docker_image}
  echo "Pushed docker image - Tag: $docker_tag"
}

_k8sbuild $@
