#!/bin/bash
# last modified 03-08-2016
set -ex

echo "DEBUG: *************************************************************"
echo "DEBUG: * THIS VERSION IS USING THE NEW DB LOAD                     *"
echo "DEBUG: *************************************************************"
echo "DEBUG: run.sh starts here"

echo "DEBUG: DOCKER_STATE = $DOCKER_STATE"

# check the variable LOCK passed from the upstart script
echo "DEBUG: checking for LOCK"

# if LOCK is set it takes precedence
if [ -z ${LOCK+x} ]; then
  echo "DEBUG: LOCK is not set; DOCKER_STATE: $DOCKER_STATE"
  # if LOCK is not set, let's check RUN_MIGRATE_OR_SEED
  # compatible with salt master version
  echo "DEBUG:run.sh:checking RUN_MIGRATE_OR_SEED"
  if [ -z ${RUN_MIGRATE_OR_SEED+x} ]; then
    echo "DEBUG: RUN_MIGRATE_OR_SEED is not set; DOCKER_STATE: $DOCKER_STATE"
    # neither is set, set to none
    echo "WARN: neither LOCK nor RUN_MIGRATE_OR_SEED set. Setting task to none"
    DOCKER_STATE=none
  else
    echo "DEBUG: RUN_MIGRATE_OR_SEED is SET $RUN_MIGRATE_OR_SEED"
    if [ "$RUN_MIGRATE_OR_SEED" = "True" ]; then
      echo "DEBUG:run.sh:leaving DOCKER_STATE alone"
    else
      DOCKER_STATE=none
      echo "DEBUG:run.sh:forcing DOCKER_STATE to none"
    fi
  fi
else
  if [ "$LOCK" = "" ]; then
    echo "DEBUG: LOCK set but empty; DOCKER_STATE: $DOCKER_STATE"
  else
    if [ $LOCK -eq 1 ]; then
      echo "DEBUG: LOCK acquired; DOCKER_STATE: $DOCKER_STATE"
    else
      if [ $LOCK -eq 0 ]; then
        echo "DEBUG: LOCK not acquired; do nothing - DOCKER_STATE: $DOCKER_STATE"
        DOCKER_STATE=none
      else
        echo "DEBUG: LOCK value not recognized: $LOCK - DOCKER_STATE: $DOCKER_STATE"
      fi
    fi
  fi
fi

set +x
echo "**********************************************"
echo "DEBUG: after IFs, DOCKER_STATE = $DOCKER_STATE"
echo "**********************************************"
set -x

case ${DOCKER_STATE} in
migrate)
    echo "executing rake db:migrate"
    bundle exec rake db:migrate
    ;;
seed)
    # db:seed
    echo "executing rake db:seed"
    bundle exec rake db:seed
    ;;
reload)
    echo "executing rake db:create + db:reload"
    bundle exec rake db:create
    bundle exec rake db:reload
    ;;
reseed)
    # db:clear
    echo "executing rake db:reseed"
    bundle exec rake db:reseed
    ;;
esac

# if REDIS_URL is not set then we start redis-server locally
if [ -z ${REDIS_URL+x} ]; then
    echo "starting redis server"
    service redis-server start
else
    echo "using remote redis server"
fi

echo "starting scheduler daemon"
bundle exec scheduler_daemon start

echo "starting sidekiq daemon"
bundle exec sidekiq -d

echo "launching unicorn"
bundle exec unicorn -p 80 -c config/unicorn.rb
