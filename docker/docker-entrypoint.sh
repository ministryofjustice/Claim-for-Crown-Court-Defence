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

if [ ! $SETTINGS__AWS__S3__ACCESS ]
then
  printf '\e[33mINFO: Removing AWS credentials from config/storage.yml\e[0m\n'
  cat config/storage.yml | grep -v access_key_id | grep -v secret_access_key > config/new_storage.yml && mv config/new_storage.yml config/storage.yml
else
  printf '\e[33mINFO: Not removing AWS credentials from config/storage.yml\e[0m\n'
fi

printf '\e[33mINFO: Starting scheduler_daemon daemon\e[0m\n'
bundle exec scheduler_daemon start

printf '\e[33mINFO: Launching unicorn\e[0m\n'
echo 'IRB.conf[:USE_AUTOCOMPLETE] = false' >> ~/.irbrc # Disable IRB autocompletion in rails console
bundle exec unicorn -p 3000 -c config/unicorn.rb
