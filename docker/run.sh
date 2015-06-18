#!/bin/bash
set -e

[ -e ping_data.sh ] && source ping_data.sh
echo "DEBUG:run.sh:BUILD_NUMBER:${BUILD_NUMBER}"
echo "DEBUG:run.sh:GIT_COMMIT:${GIT_COMMIT}"
echo "DEBUG:run.sh:BUILD_ID:${BUILD_ID}"
echo "DEBUG:run.sh:BUILD_DATE:${BUILD_DATE}"

case ${DOCKER_STATE} in
migrate)
    echo "running migrate"
    bundle exec rake db:migrate
    ;;
seed)
    echo "running seed"
    bundle exec rake db:drop
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    bundle exec rake claims:demo_data
    ;;
esac
exec bundle exec unicorn -p 80
