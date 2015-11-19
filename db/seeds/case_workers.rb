require 'csv'
require Rails.root.join('db','seeds','seed_helper')


days_worked = [
  [ 1, 1, 1, 1, 1 ],
  [ 1, 1, 1, 1, 0 ],
  [ 0, 0, 1, 1, 1 ],
]


# create test/dummy case workers
SeedHelper.find_or_create_caseworker!(
  first_name: 'Dave',
  last_name: 'Smith',
  email: 'caseworker@example.com',
  days_worked: [ 1,1,1,1,0],
  location: 'Nottingham',
  role: 'case_worker',
  password_env_var: 'CASE_WORKER_PASSWORD')

SeedHelper.find_or_create_caseworker!(
  first_name: 'Bill',
  last_name: 'Smith',
  email: 'caseworkeradmin@example.com',
  days_worked: [ 1,1,1,1,1],
  location: 'Nottingham',
  role: 'admin',
  password_env_var: 'ADMIN_PASSWORD')

# create actual case workers
file_path = Rails.root.join('lib', 'assets', 'data', 'case_workers.csv')
data = CSV.read(file_path)
data.shift

data.each_with_index do |row, index|
  fname, lname, email, location, role = row
  SeedHelper.find_or_create_caseworker!(
    first_name: fname,
    last_name: lname,
    email: email,
    location: location,
    role: role,
    days_worked: days_worked[ index % 3 ],
    password_env_var: 'CASE_WORKER_PASSWORD')
end
