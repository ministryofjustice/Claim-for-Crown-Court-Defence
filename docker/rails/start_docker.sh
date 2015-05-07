#!/bin/bash
# using an RDS instance created manually to test dockerization
docker run -p 80:80 \
		-it \
		-e CBO_BASE_DATABASE_DATABASE=cbo_test \
		-e CBO_BASE_DATABASE_USERNAME=cbo_dev_test \
		-e CBO_BASE_DATABASE_PASSWORD=cbo-dev-test \
		-e CBO_BASE_DATABASE_HOST=cbo-dev-test.cefwt7a3h2hb.eu-west-1.rds.amazonaws.com \
		-e SECRET_KEY_BASE='00836b907753f2a24649c802d53d0440b461afd8678eeb8a9db7b6d6611f2cc4ade89b05d43d6c9c5de4ee83fc43af23ca75ba7d883664138c2fd35dca39c466' \
		-e RAILS_ENV=production cbo-test 

