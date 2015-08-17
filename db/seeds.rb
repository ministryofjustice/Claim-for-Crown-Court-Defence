%w(
  case_types
  schemes
  offence_classes
  offences
  fee_categories
  fee_types
  expense_types
  locations
  case_workers
  advocates
  courts
  chambers
  vat_rates
).
each do |seed|
  puts "Seeding '#{seed}'..."
  load File.join(Rails.root, 'db', 'seeds', "#{seed}.rb")
end
