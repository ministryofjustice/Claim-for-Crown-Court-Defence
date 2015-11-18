%w(
  case_types
  offence_classes
  offences
  fee_categories
  fee_types
  expense_types
  locations
  case_workers
  advocates
  super_admins
  courts
  chambers
  vat_rates
).
each do |seed|
  puts "Seeding '#{seed}'..."
  load File.join(Rails.root, 'db', 'seeds', "#{seed}.rb")
end
