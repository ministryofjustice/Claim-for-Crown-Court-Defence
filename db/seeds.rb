%w(
  fee_categories
  fee_types
  expense_types
  admins
  case_workers
  advocates
  courts
).
each do |seed|
  puts "Seeding '#{seed}'..."
  load File.join(Rails.root, 'db', 'seeds', "#{seed}.rb")
end
