#!/bin/bash
set -e
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
    bundle exec rake claims:all_states[25]
    ;;
esac
exec bundle exec unicorn -p 80
