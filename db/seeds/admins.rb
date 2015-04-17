User.create!(
  email: 'admin@example.com',
  password: ENV['ADMIN_PASSWORD'],
  password_confirmation: ENV['ADMIN_PASSWORD'],
  role: 'admin') if User.find_by(email: 'admin@example.com').blank?
