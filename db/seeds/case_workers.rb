require 'csv'

CaseWorker.delete_all

# create test/dummy case workers
if User.find_by(email: 'caseworker@example.com').blank?
  user = User.create!(
    first_name: 'Dave',
    last_name: 'Smith',
    email: 'caseworker@example.com',
    password: ENV['CASE_WORKER_PASSWORD'],
    password_confirmation: ENV['CASE_WORKER_PASSWORD']
  )

  case_worker = CaseWorker.new(role: 'case_worker')
  case_worker.user = user
  case_worker.location = Location.find_or_create_by!(name: 'Nottingham')
  case_worker.save!
end

if User.find_by(email: 'caseworkeradmin@example.com').blank?
  user = User.create!(
    first_name: 'Bill',
    last_name: 'Smith',
    email: 'caseworkeradmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  case_worker = CaseWorker.new(role: 'admin')
  case_worker.user = user
  case_worker.location = Location.find_or_create_by!(name: 'Nottingham')
  case_worker.save!
end


# create actual case workers
file_path = Rails.root.join('lib', 'assets', 'data', 'case_workers.csv')
data = CSV.read(file_path)
data.shift

data.each do |row|
  fname, lname, email, location = row

  user = User.create!(
    first_name: fname,
    last_name: lname,
    email: email,
    password: ENV['CASE_WORKER_PASSWORD'],
    password_confirmation: ENV['CASE_WORKER_PASSWORD']
  )

  case_worker = CaseWorker.new(role: 'case_worker')
  case_worker.user = user
  case_worker.location = Location.find_or_create_by!(name: location.capitalize)
  case_worker.save!
end
