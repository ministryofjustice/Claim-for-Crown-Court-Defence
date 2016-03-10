require 'csv'
require Rails.root.join('db','seeds','seed_helper')

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
  roles: ['admin'],
  password_env_var: 'ADMIN_PASSWORD'
)
