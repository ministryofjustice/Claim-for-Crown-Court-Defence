if User.find_by(email: 'caseworker@example.com').blank?
  user = User.create!(
    first_name: 'John',
    last_name: 'Smith',
    email: 'caseworker@example.com',
    password: ENV['CASE_WORKER_PASSWORD'],
    password_confirmation: ENV['CASE_WORKER_PASSWORD']
  )

  case_worker = CaseWorker.new(role: 'case_worker')
  case_worker.user = user
  case_worker.save!
end

if User.find_by(email: 'caseworkeradmin@example.com').blank?
  user = User.create!(
    first_name: 'John',
    last_name: 'Smith',
    email: 'caseworkeradmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  case_worker = CaseWorker.new(role: 'admin')
  case_worker.user = user
  case_worker.save!
end
