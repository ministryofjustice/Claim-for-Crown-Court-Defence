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
    password_env_var: 'CASE_WORKER_PASSWORD'
  )
end

# create an application user CCR
SeedHelper.find_or_create_caseworker!(
  first_name: 'CCR Injection',
  last_name: 'DO NOT DELETE',
  email: 'ccr@example.com',
  location: 'Nottingham',
  roles: %w[admin case_worker],
  password_env_var: 'CASE_WORKER_PASSWORD'
)

ccr_caseworker_api_key = ENV.fetch('CCR_CASEWORKER_API_KEY', nil)
if ccr_caseworker_api_key
  usr = User.find_by(email: 'ccr@example.com')
  usr.update(api_key: ccr_caseworker_api_key) if !usr.api_key.eql?(ccr_caseworker_api_key)
end

# create an application user CCLF
SeedHelper.find_or_create_caseworker!(
  first_name: 'CCLF Injection',
  last_name: 'DO NOT DELETE',
  email: 'cclf@example.com',
  location: 'Nottingham',
  roles: %w[admin case_worker],
  password_env_var: 'CASE_WORKER_PASSWORD'
)

cclf_caseworker_api_key = ENV.fetch('CCLF_CASEWORKER_API_KEY', nil)
if cclf_caseworker_api_key
  usr = User.find_by(email: 'cclf@example.com')
  usr.update(api_key: cclf_caseworker_api_key) if !usr.api_key.eql?(cclf_caseworker_api_key)
end
