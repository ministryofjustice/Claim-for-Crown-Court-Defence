#!/bin/sh
set -ex

printf '\e[33mExecuting smoke test\e[0m\n'

# sleep 10 # waits for the postgres database to setup first

# bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails api:smoke_test
