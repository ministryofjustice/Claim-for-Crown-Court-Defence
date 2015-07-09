require 'csv'
require Rails.root.join('db','seeds','seed_helper')

# create test/dummy case workers
SeedHelper.find_or_create_caseworker!(first_name: 'Dave', last_name: 'Smith', email: 'caseworker@example.com', location: 'Nottingham', role: 'case_worker', password_env_var: 'CASE_WORKER_PASSWORD')
SeedHelper.find_or_create_caseworker!(first_name: 'Bill', last_name: 'Smith', email: 'caseworkeradmin@example.com', location: 'Nottingham', role: 'admin', password_env_var: 'ADMIN_PASSWORD')

# create actual case workers
file_path = Rails.root.join('lib', 'assets', 'data', 'case_workers.csv')
data = CSV.read(file_path)
data.shift

data.each do |row|
  fname, lname, email, location = row
  SeedHelper.find_or_create_caseworker!(first_name: fname, last_name: lname, email: email, location: location, role: 'case_worker', password_env_var: 'CASE_WORKER_PASSWORD')
end
