User.create(
  email: 'advocate@example.com',
  password: ENV['ADVOCATE_PASSWORD'],
  password_confirmation: ENV['ADVOCATE_PASSWORD'],
  role: 'advocate') if User.find_by(email: 'advocate@example.com').blank?
