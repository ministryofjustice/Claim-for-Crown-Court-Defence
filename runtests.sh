#!/bin/bash -e
# Script executing all the test tasks.
rake db:clear
rake db:migrate
rake db:seed
rake claims:allocated[38]
rake claims:completed[10]
rspec