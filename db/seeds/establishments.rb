ESTABLISHMENTS = [
  { name: 'Example Crown Court', category: 'crown_court', postcode: 'SW1A 1AA' },
  { name: 'Another Crown Court', category: 'crown_court', postcode: 'M1 1AA' },
  { name: 'Example Magistrates Court', category: 'magistrates_court', postcode: 'LS1 1AA' },
  { name: 'Another Magistrates Court', category: 'magistrates_court', postcode: 'B1 1BB' },
  { name: 'Example Prison', category: 'prison', postcode: 'NE1 1AA' },
  { name: 'Another Prison', category: 'prison', postcode: 'CF10 1AA' },
  { name: 'Example Hospital', category: 'hospital', postcode: 'EC1A 1BB' },
  { name: 'Another Hospital', category: 'hospital', postcode: 'BS1 1AA' }
].freeze

ESTABLISHMENTS.each do |attrs|
  Establishment.find_or_create_by!(name: attrs[:name], category: attrs[:category]) do |e|
    e.postcode = attrs[:postcode]
  end
end
