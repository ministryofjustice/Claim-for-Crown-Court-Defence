provider = Provider.find_or_create_by!(name: 'Test firm A', supplier_number: 'A1234567', api_key: ENV['TEST_CHAMBER_API_KEY'], provider_type: 'firm', vat_registered: true)

if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    first_name: 'Bob',
    last_name: 'Smith',
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(role: 'advocate', provider_id: provider.id)
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

  advocate = Advocate.new(role: 'admin', provider_id: provider.id)
  advocate.user = user
  advocate.save!
end

#Create an advocate who belongs to a firm

provider = Provider.find_or_create_by!(name: 'Test firm B', supplier_number: 'B1234567', api_key: ENV['TEST_CHAMBER_API_KEY'], provider_type: 'firm', vat_registered: false)

if User.find_by(email: 'advocatefirm@example.com').blank?
  user = User.create!(
    first_name: 'Tom',
    last_name: 'Jones',
    email: 'advocatefirm@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(role: 'advocate', provider_id: provider.id)
  advocate.user = user
  advocate.save!
end

if User.find_by(email: 'advocatefirmadmin@example.com').blank?
  user = User.create!(
    first_name: 'May',
    last_name: 'Smith',
    email: 'advocatefirmadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  advocate = Advocate.new(role: 'admin', provider_id: provider.id)
  advocate.user = user
  advocate.save!
end

# Create an advocate who belongs to a chamber

provider = Provider.find_or_create_by!(name: 'Test chamber', api_key: ENV['TEST_CHAMBER_API_KEY'], provider_type: 'chamber')

if User.find_by(email: 'advocatechamber@example.com').blank?
  user = User.create!(
    first_name: 'Charlie',
    last_name: 'Brown',
    email: 'advocatechamber@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  advocate = Advocate.new(role: 'advocate', provider_id: provider.id, supplier_number: 'XA123')
  advocate.user = user
  advocate.save!
end

if User.find_by(email: 'advocatechamberadmin@example.com').blank?
  user = User.create!(
    first_name: 'William',
    last_name: 'Smith',
    email: 'advocatechamberadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  advocate = Advocate.new(role: 'admin', provider_id: provider.id, supplier_number: 'XA123')
  advocate.user = user
  advocate.save!
end
