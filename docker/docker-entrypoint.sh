#!/bin/sh
# last modified 17-05-2019
set +ex

# output gets written to /var/log/upstart/... with template-deploy
#
case ${DOCKER_STATE} in
migrate)
    printf '\e[33mINFO: executing rake db:migrate\e[0m\n'
    bundle exec rake db:migrate
    ;;
seed)
    printf '\e[33mINFO: executing rake db:seed\e[0m\n'
    bundle exec rake db:seed
    ;;
reload)
    printf '\e[33mINFO: executing rake db:create + db:reload\e[0m\n'
    bundle exec rake db:create
    bundle exec rake db:reload
    ;;
reseed)
    printf '\e[33mINFO: executing rake db:reseed\e[0m\n'
    bundle exec rake db:reseed
    ;;
esac

set -ex

# if REDIS_URL is not set then we start redis-server locally
if [ -z ${REDIS_URL+x} ]; then
  printf '\e[33mINFO: Starting redis-server daemon\e[0m\n'
  redis-server --daemonize yes
else
  printf '\e[33mINFO: Using remote redis-server\e[0m\n'
fi

# printf '\e[33mINFO: Starting sidekiq daemon\e[0m\n'
# bundle exec sidekiq -d

# printf '\e[33mINFO: Starting scheduler_daemon daemon\e[0m\n'
# bundle exec scheduler_daemon start

# printf '\e[33mINFO: Launching unicorn\e[0m\n'
# bundle exec unicorn -p 3000 -c config/unicorn.rb

printf '\e[33mINFO: Starting services \e[0m\n'
supervisord --nodaemon -c /usr/src/app/docker/supervisord.conf
