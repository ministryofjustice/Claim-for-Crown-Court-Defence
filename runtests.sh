#!/bin/bash -e
# Script executing all the test tasks.
bundle exec rake db:migrate test
