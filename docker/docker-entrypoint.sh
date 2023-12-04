#!/bin/sh
# last modified 17-05-2019
set +ex

case ${LIVE1_DB_TASK} in
migrate)
    printf '\e[33mINFO: executing rake db:migrate\e[0m\n'
    bundle exec rake db:migrate
    ;;
esac

set -ex

# if REDIS_URL is not set then we start redis-server locally
if [ -z ${REDIS_URL+x} ]; then
  printf '\e[33mINFO: Starting redis-server daemon\e[0m\n'
  redis-server --daemonize yes
else
  printf '\e[33mINFO: Using remote redis-server specified in REDIS_URL\e[0m\n'
fi

printf '\e[33mINFO: Starting scheduler_daemon daemon\e[0m\n'
bundle exec scheduler_daemon start

printf '\e[33mINFO: Launching puma\e[0m\n'
echo 'IRB.conf[:USE_AUTOCOMPLETE] = false' >> ~/.irbrc # Disable IRB autocompletion in rails console
bundle exec puma -p 3000
