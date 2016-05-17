#!/bin/bash
set -ex
# set variables. It's presumed the absence of these is causing
# TRAVIS to fail
if [ "$TRAVIS" = "true" ]; then
  echo "INFO: this is travis - not running smoke test"
  bundle exec rake db:migrate
  #bundle exec rake jasmine:ci
  bundle exec rake

  exit 0
else
  # Script executing all the test tasks.
  bundle exec rake db:migrate
  # execute smoke test - needs seeded tables
  bundle exec rake db:seed

  echo "INFO: EXECUTING SMOKE TEST <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  bundle exec rake api:smoke_test
fi
