chamber = Chamber.find_or_create_by!(name: 'Test chamber/firm', supplier_number: 'A1234567')

if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    first_name: 'Bob',
    last_name: 'Smith',
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(role: 'advocate', chamber_id: chamber.id, supplier_number: 'AB234')
  advocate.user = user
  advocate.save!
end

if User.find_by(email: 'advocateadmin@example.com').blank?
  user = User.create!(
    first_name: 'John',
    last_name: 'Smith',
    email: 'advocateadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  advocate = Advocate.new(role: 'admin', chamber_id: chamber.id, supplier_number: 'XY234')
  advocate.user = user
  advocate.save!
end
