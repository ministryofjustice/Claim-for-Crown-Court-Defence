#!/bin/bash
set -e

if [ "$DOCKER_STATE" = "none" ]; then
  SLEEP_TIME=0
else
  if [ "$RUN_MIGRATE_OR_SEED" != "True" ]; then
      SLEEP_TIME=5m
      DOCKER_STATE=none
  fi
fi

case ${DOCKER_STATE} in
migrate)
    bundle exec rake db:migrate
    ;;
seed)
    # db:reload  a bespoke task, see lib/tasks/db.rake
    bundle exec rake db:reload
    ;;
esac
if [ -n "$SLEEP_TIME" ]; then
  sleep $SLEEP_TIME
fi

exec bundle exec unicorn -p 80
