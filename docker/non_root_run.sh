#!/bin/sh
# last modified 10-05-2019
set -ex

# if REDIS_URL is not set then we start redis-server locally
if [ -z ${REDIS_URL+x} ]; then
    echo "starting redis server"
    redis-server --daemonize yes
else
    echo "using remote redis server"
fi

# Start scheduler daemon"
bundle exec scheduler_daemon start

# Start sidekiq daemon"
bundle exec sidekiq -d

echo "launching unicorn"
bundle exec unicorn -p 3000 -c config/unicorn.rb
