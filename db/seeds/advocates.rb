if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(first_name: 'John', last_name: 'Smith', role: 'advocate')
  advocate.user = user
  advocate.save!
end

if User.find_by(email: 'advocateadmin@example.com').blank?
  user = User.create!(
    email: 'advocateadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  advocate = Advocate.new(first_name: 'John', last_name: 'Smith', role: 'admin')
  advocate.user = user
  advocate.save!
end
