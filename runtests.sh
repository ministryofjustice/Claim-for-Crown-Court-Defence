#!/bin/bash
set -ex
# Script executing all the test tasks.
bundle exec rake db:migrate test
