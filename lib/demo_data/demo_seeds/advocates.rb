provider = Provider.find_or_create_by!(name: 'Test chamber/firm', supplier_number: 'A1234567', api_key: ENV['TEST_CHAMBER_API_KEY'], provider_type: 'firm')

if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    first_name: 'Bob',
    last_name: 'Smith',
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(role: 'advocate', provider_id: provider.id, supplier_number: 'AB234')
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

  advocate = Advocate.new(role: 'admin', provider_id: provider.id, supplier_number: 'XY234')
  advocate.user = user
  advocate.save!
end
