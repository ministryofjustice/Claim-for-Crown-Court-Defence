chamber = Chamber.create!(name: 'Test chamber/firm', account_number: 'A1234567')

if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(first_name: 'John', last_name: 'Smith', role: 'advocate', chamber_id: chamber.id)
  advocate.user = user
  advocate.save!
end

if User.find_by(email: 'advocateadmin@example.com').blank?
  user = User.create!(
    email: 'advocateadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  advocate = Advocate.new(first_name: 'John', last_name: 'Smith', role: 'admin', chamber_id: chamber.id)
  advocate.user = user
  advocate.save!
end
