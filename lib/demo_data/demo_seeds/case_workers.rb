require 'csv'
require Rails.root.join('db','seeds','seed_helper')

SeedHelper.find_or_create_caseworker!(
  first_name: 'Dave',
  last_name: 'Smith',
  email: 'caseworker@example.com',
  days_worked: [ 1,1,1,1,0],
  location: 'Nottingham',
  roles: ['case_worker'],
  password_env_var: 'CASE_WORKER_PASSWORD'
)

SeedHelper.find_or_create_caseworker!(
  first_name: 'Bill',
  last_name: 'Smith',
  email: 'caseworkeradmin@example.com',
  days_worked: [ 1,1,1,1,1],
  location: 'Nottingham',
  roles: ['admin'],
  password_env_var: 'ADMIN_PASSWORD'
)
