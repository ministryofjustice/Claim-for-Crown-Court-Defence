require Rails.root.join('db','seed_helper')

# NOTE:
#   the following provider names can be destroyed using the claims destroyer
#   and should therefore be used so that we can "clean-up" data on staging
#   and gamma (be very careful)
#
# SAMPLE_PROVIDERS = ['Test chamber','Test firm A', 'Test firm B']
#
#  #destroy the above providers and all their users and claims
#  rake claims.destroy_sample_providers
#

# Create an advocate and admin/clerk for AGFS Chamber
# -------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test chamber',
  supplier_number: nil,
  api_key: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'chamber',
  vat_registered: true,
  roles: ['agfs']
)

if User.find_by(email: 'advocate@example.com').blank?
  user = User.create!(
    first_name: 'Barry',
    last_name: 'Stir',
    email: 'advocate@example.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD'],
  )

  external_user = ExternalUser.new(roles: ['advocate'], supplier_number: '11AAA', provider_id: provider.id)
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

# Create a litigator and admin/clerk belonging to an LGFS Firm
# -------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test firm A',
  supplier_number: '1A222',
  # api_key: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'firm',
  vat_registered: true,
  roles: ['lgfs'],
  supplier_numbers: SeedHelper.build_supplier_numbers(%w(1A222Z 2A333Z 3A555Z))
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

# create an admin/clerk that belongs to an AGFS and LGFS Firm
# The firm has a single advocate (does not need a litigator as
# litigator claims are not "owned" by anyone except the firm)
# ------------------------------------------------------------
provider = SeedHelper.find_or_create_provider!(
  name: 'Test firm B',
  supplier_number: '22BBB',
  # api_key: ENV['TEST_CHAMBER_API_KEY'],
  provider_type: 'firm',
  vat_registered: false,
  roles: ['agfs','lgfs'],
  supplier_numbers: SeedHelper.build_supplier_numbers(%w(1B222Z 2B333Z 3B555Z))
)

if User.find_by(email: 'advocate@agfslgfs.com').blank?
  user = User.create!(
    first_name: 'Adi',
    last_name: 'Firmstein',
    email: 'advocate@agfslgfs.com',
    password: ENV['ADVOCATE_PASSWORD'],
    password_confirmation: ENV['ADVOCATE_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['advocate'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end


if User.find_by(email: 'admin@agfslgfs.com').blank?
  user = User.create!(
    first_name: 'Adliti',
    last_name: 'Vogator-Admin',
    email: 'admin@agfslgfs.com',
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end

if User.find_by(email: 'litigator@agfslgfs.com').blank?
  user = User.create!(
      first_name: 'Adliti',
      last_name: 'Gator',
      email: 'litigator@agfslgfs.com',
      password: ENV['ADMIN_PASSWORD'],
      password_confirmation: ENV['ADMIN_PASSWORD']
  )

  external_user = ExternalUser.new(roles: ['litigator'], provider_id: provider.id)
  external_user.user = user
  external_user.save!
end


# Create advocates belonging to an AGFS Firm - EDGE CASE
# -------------------------------------------------------
# provider = SeedHelper.find_or_create_provider!(
#   name: 'Test firm C',
#   supplier_number: 'C1234567',
#   api_key: ENV['TEST_CHAMBER_API_KEY'],
#   provider_type: 'firm',
#   vat_registered: false,
#   roles: ['agfs']
# )

# if User.find_by(email: 'advocatefirm@example.com').blank?
#   user = User.create!(
#     first_name: 'Tom',
#     last_name: 'Jones',
#     email: 'advocatefirm@example.com',
#     password: ENV['ADVOCATE_PASSWORD'],
#     password_confirmation: ENV['ADVOCATE_PASSWORD']
#   )

#   external_user = ExternalUser.new(roles: ['advocate'], provider_id: provider.id)
#   external_user.user = user
#   external_user.save!
# end

# if User.find_by(email: 'advocatefirmadmin@example.com').blank?
#   user = User.create!(
#     first_name: 'May',
#     last_name: 'Smith',
#     email: 'advocatefirmadmin@example.com',
#     password: ENV['ADMIN_PASSWORD'],
#     password_confirmation: ENV['ADMIN_PASSWORD']
#   )

#   external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
#   external_user.user = user
#   external_user.save!
# end

# Create an advocate belonging to an AGFS and LGFS chamber
# NOTE: these would never actually exist as chambers only have advocates by definition
# -------------------------------------------------------
# provider = SeedHelper.find_or_create_provider!(
#   name: 'Test chamber',
#   api_key: ENV['TEST_CHAMBER_API_KEY'],
#   provider_type: 'chamber',
#   vat_registered: true,
#   roles: ['agfs', 'lgfs']
# )

# if User.find_by(email: 'advocatechamber@example.com').blank?
#   user = User.create!(
#     first_name: 'Charlie',
#     last_name: 'Brown',
#     email: 'advocatechamber@example.com',
#     password: ENV['ADVOCATE_PASSWORD'],
#     password_confirmation: ENV['ADVOCATE_PASSWORD']
#   )

#   external_user = ExternalUser.new(roles: ['advocate'], provider_id: provider.id, supplier_number: 'AX123')
#   external_user.user = user
#   external_user.save!
# end

# if User.find_by(email: 'advocatechamberadmin@example.com').blank?
#   user = User.create!(
#     first_name: 'William',
#     last_name: 'Smith',
#     email: 'advocatechamberadmin@example.com',
#     password: ENV['ADMIN_PASSWORD'],
#     password_confirmation: ENV['ADMIN_PASSWORD']
#   )

#   external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
#   external_user.user = user
#   external_user.save!
# end


# Create an advocate/litigator who belongs to a AGFS and LGFS firm - EDGE CASE
# -------------------------------------------------------
# provider = SeedHelper.find_or_create_provider!(
#   name: 'Test firm D',
#   supplier_number: 'D1234567',
#   api_key: ENV['TEST_CHAMBER_API_KEY'],
#   provider_type: 'firm',
#   vat_registered: true,
#   roles: ['agfs','lgfs']
# )

# if User.find_by(email: 'advocatelitigator@example.com').blank?
#   user = User.create!(
#     first_name: 'AdiLiti',
#     last_name: 'Gator',
#     email: 'advocatelitigator@example.com',
#     password: ENV['ADVOCATE_PASSWORD'],
#     password_confirmation: ENV['ADVOCATE_PASSWORD']
#   )

#   external_user = ExternalUser.new(roles: ['advocate','litigator'], provider_id: provider.id)
#   external_user.user = user
#   external_user.save!
# end

# if User.find_by(email: 'litigatoradmin@example.com').blank?
#   user = User.create!(
#     first_name: 'AdiLiti',
#     last_name: 'Gator-Admin',
#     email: 'advocatelitigatoradmin@example.com',
#     password: ENV['ADMIN_PASSWORD'],
#     password_confirmation: ENV['ADMIN_PASSWORD']
#   )

#   external_user = ExternalUser.new(roles: ['admin'], provider_id: provider.id)
#   external_user.user = user
#   external_user.save!
# end