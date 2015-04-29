if User.find_by(email: 'admin@example.com').blank?
  user = User.create!(
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new
  advocate.user = user
  advocate.save!
end