#!/bin/sh
set -ex

printf '\e[33mbundle show\e[0m\n'
which -a bundle
bundle show
bundle exec ruby -v
bundle exec rails -v

printf '\e[33mExecuting smoke test\e[0m\n'
# bundle exec rails db:migrate:status
# bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake api:smoke_test
