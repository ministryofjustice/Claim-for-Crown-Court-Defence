#!/bin/bash
set -ex
# set variables. It's presumed the absence of these is causing
# TRAVIS to fail
if [ "$TRAVIS" = "true" ]; then
  printf '\e[32mLoading Schema\e[0m'
  bundle exec rake db:schema:load
  bundle exec rake jasmine:ci
  bundle exec rake spec
  printf "\e[33mSleeping for two seconds to give CPU time to cool down and perhaps not fail on the cuke tasks because drop down lists aren't populated fast enough\e[0m"
  sleep 2
  bundle exec rake cucumber

  exit 0
else
  # Script executing all the test tasks.
  bundle exec rake db:migrate
  # execute smoke test - needs seeded tables
  bundle exec rake db:seed

  printf "\e[33mINFO: EXECUTING SMOKE TEST\e[0m"
  bundle exec rake api:smoke_test
fi
