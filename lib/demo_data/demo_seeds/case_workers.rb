# frozen_string_literal: true

# eager loading in test env could load this file
# should probably be more fine grained with eager_load_paths
return if Rails.env.test?

require 'csv'
require Rails.root.join('db','seed_helper')

SeedHelper.find_or_create_caseworker!(
  first_name: 'Casey',
  last_name: 'Worker',
  email: 'caseworker@example.com',
  location: 'Nottingham',
  roles: ['case_worker'],
  password_env_var: 'CASE_WORKER_PASSWORD'
)

SeedHelper.find_or_create_caseworker!(
  first_name: 'Casey',
  last_name: 'Worker-Admin',
  email: 'caseworkeradmin@example.com',
  location: 'Nottingham',
  roles: ['admin','provider_management'],
  password_env_var: 'ADMIN_PASSWORD'
)
