#!/bin/bash
echo "inside run.sh"
cd /rails

case ${DOCKER_STATE} in
migrate)
    echo "running migrate"
    bundle exec rake db:migrate
    ;;
seed)
    echo "running seed"
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ;;
esac
bundle exec unicorn -p 80