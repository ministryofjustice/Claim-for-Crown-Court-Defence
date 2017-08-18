#!/bin/bash
set -ex
# set variables. It's presumed the absence of these is causing
# TRAVIS to fail
if [ "$TRAVIS" = "true" ]; then
  printf '\e[32mInfo: Loading Schema\e[0m\n'
  bundle exec rake db:schema:load
  bundle exec rake ci:test_suite
  exit 0
else
  printf '\e[33mInfo: Executing smoke test\e[0m\n'
  bundle exec rake db:migrate
  bundle exec rake db:seed
  bundle exec rake api:smoke_test
fi
