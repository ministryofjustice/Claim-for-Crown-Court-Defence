User.create!(
  email: 'caseworker@example.com',
  password: ENV['CASE_WORKER_PASSWORD'],
  password_confirmation: ENV['CASE_WORKER_PASSWORD'],
  role: 'case_worker')
