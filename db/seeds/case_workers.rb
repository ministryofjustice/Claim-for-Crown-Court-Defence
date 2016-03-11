require 'csv'
require Rails.root.join('db','seed_helper')

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
    roles: [role],
    password_env_var: 'CASE_WORKER_PASSWORD')
end
