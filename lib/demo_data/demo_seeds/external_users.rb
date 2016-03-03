require Rails.root.join('db','seeds','seed_helper')

# Create a external users for AGFS firm
# -------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test firm A',
  supplier_number: 'A1234567',
  api_key_env_var: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'firm',
  vat_registered: true,
  roles: ['agfs']
)

if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    first_name: 'Barry',
    last_name: 'Stir',
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['advocate'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

if User.find_by(email: 'advocateadmin@example.com').blank?
  user = User.create!(
    first_name: 'Advo',
    last_name: 'Kate-Admin',
    email: 'advocateadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

# Create a external users for LGFS firm
# -------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test firm B',
  supplier_number: 'B1234567',
  api_key: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'firm',
  vat_registered: true,
  roles: ['lgfs']
)

if User.find_by(email: 'litigator@example.com').blank?
  user = User.create!(
    first_name: 'Liti',
    last_name: 'Gator',
    email: 'litigator@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['litigator'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

if User.find_by(email: 'litigatoradmin@example.com').blank?
  user = User.create!(
    first_name: 'Liti',
    last_name: 'Gator-Admin',
    email: 'litigatoradmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

# Create external users belonging to AGFS firm
# -------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test firm C',
  supplier_number: 'C1234567',
  api_key_env_var: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'firm',
  vat_registered: false,
  roles: ['agfs']
)

if User.find_by(email: 'advocatefirm@example.com').blank?
  user = User.create!(
    first_name: 'Tom',
    last_name: 'Jones',
    email: 'advocatefirm@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['advocate'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

if User.find_by(email: 'advocatefirmadmin@example.com').blank?
  user = User.create!(
    first_name: 'May',
    last_name: 'Smith',
    email: 'advocatefirmadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

# Create an external_user who belongs to a AGFS and LGFS chamber
# NOTE: these would never actually exist as chambers only have advocates by definition
# -------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test chamber',
  api_key_env_var: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'chamber',
  vat_registered: true,
  roles: ['agfs', 'lgfs']
)

if User.find_by(email: 'advocatechamber@example.com').blank?
  user = User.create!(
    first_name: 'Charlie',
    last_name: 'Brown',
    email: 'advocatechamber@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['advocate'], provider_id: provider.id, supplier_number: 'XA123')
  external_user.user = user
  external_user.save!
end

if User.find_by(email: 'advocatechamberadmin@example.com').blank?
  user = User.create!(
    first_name: 'William',
    last_name: 'Smith',
    email: 'advocatechamberadmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id, supplier_number: 'XA123')
  external_user.user = user
  external_user.save!
end


# Create an external_user who belongs to a AGFS and LGFS firm
# -------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test firm D',
  supplier_number: 'D1234567',
  api_key: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'firm',
  vat_registered: true,
  roles: ['agfs','lgfs']
)

if User.find_by(email: 'advocatelitigator@example.com').blank?
  user = User.create!(
    first_name: 'AdiLiti',
    last_name: 'Gator',
    email: 'advocatelitigator@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['advocate','litigator'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

if User.find_by(email: 'litigatoradmin@example.com').blank?
  user = User.create!(
    first_name: 'AdiLiti',
    last_name: 'Gator-Admin',
    email: 'advocatelitigatoradmin@example.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end