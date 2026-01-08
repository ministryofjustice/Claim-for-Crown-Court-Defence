# Seed all lookup data
# - order is important to handle foreign key dependencies
#

# Use this to generate a list of seed files in alphabtical order
# which you can then tweak in load list below
#
# Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
#   file_name = File.basename(seed, '.*')
#   puts file_name
#   # puts "load 'db/seeds/#{file_name}'"
# end

SEED_FILES = %w[
  case_types
  case_stages
  case_workers
  certification_types
  courts
  disbursement_types
  establishments
  expense_types
  fee_types
  locations
  offence_classes
  offences
  scheme_10
  scheme_11
  scheme_12
  super_admins
  supplier_numbers
  vat_rates
  lgfs_scheme_10
  scheme_13
  scheme_14
  scheme_15
  scheme_16
  lgfs_scheme_11
]

SEED_FILES.each do |file|
  file_path = "db/seeds/#{file}.rb"
  puts "loading #{file_path}..."
  load file_path
end
