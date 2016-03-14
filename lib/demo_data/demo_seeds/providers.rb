require Rails.root.join('db','seed_helper')

SeedHelper.find_or_create_provider!(
  name: 'Doughty Street Chambers',
  provider_type: 'chamber',
  roles: ['agfs']
)

SeedHelper.find_or_create_provider!(
  name: 'Matrix Chambers',
  provider_type: 'chamber',
  roles: ['lgfs']
)
