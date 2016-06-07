#!/bin/bash
set -ex
# set variables. It's presumed the absence of these is causing
# TRAVIS to fail
if [ "$TRAVIS" = "true" ]; then
  echo "INFO: this is travis - not running smoke test"
  bundle exec rake db:migrate
  bundle exec rake jasmine:ci
  bundle exec rake spec
  puts ">>>>>>>>>>  SLEEPING FOR ONE SECOND TO GIVE CPU TIME TO COOL DOWN AND PERHAPS NOT FAIL ON THE CUKE TASKS BECAUSE DROP DOWN LISTS AREN'T POPULATED FAST ENOUGH <<<<<<"
  sleep 2
  bundle exec rake cucumber

  exit 0
else
  # Script executing all the test tasks.
  bundle exec rake db:migrate
  # execute smoke test - needs seeded tables
  bundle exec rake db:seed

  echo "INFO: EXECUTING SMOKE TEST <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  bundle exec rake api:smoke_test
fi
