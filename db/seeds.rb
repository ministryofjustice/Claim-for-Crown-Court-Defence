%w(
  schemes
  offence_classes
  offences
  document_types
  fee_categories
  fee_types
  expense_types
  case_workers
  advocates
  courts
  chambers
  evidence_list_items
).
each do |seed|
  puts "Seeding '#{seed}'..."
  load File.join(Rails.root, 'db', 'seeds', "#{seed}.rb")
end
