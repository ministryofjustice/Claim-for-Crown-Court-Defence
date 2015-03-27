%w(
  fee_types
  fees
  expense_types
  case_workers
  advocates
).
each do |seed|
  puts "Seeding '#{seed}'..."
  load File.join(Rails.root, 'db', 'seeds', "#{seed}.rb")
end
