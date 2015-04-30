if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(first_name: 'John', last_name: 'Smith')
  advocate.user = user
  advocate.save!
end
