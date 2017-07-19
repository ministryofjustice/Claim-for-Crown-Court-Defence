#!/bin/bash
set -ex
# set variables. It's presumed the absence of these is causing
# TRAVIS to fail
if [ "$TRAVIS" = "true" ]; then
  printf '\e[32mInfo: Loading Schema\e[0m'
  bundle exec rake db:schema:load
  bundle exec rake jasmine:ci
  bundle exec rake spec
  printf "\e[33mInfo: Sleeping for two seconds to give CPU time to cool down and perhaps not fail on the cuke tasks because drop down lists aren't populated fast enough\e[0m"
  sleep 2
  bundle exec rake cucumber

  exit 0
else
  printf "\e[33mInfo: Executing smoke test\e[0m"
  bundle exec rake db:migrate
  bundle exec rake db:seed
  bundle exec rake api:smoke_test
fi
