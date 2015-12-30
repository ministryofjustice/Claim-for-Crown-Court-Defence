%w(
  advocates
  providers
  case_workers
).
each do |seed|
  puts "Seeding '#{seed}'..."
  load File.join(Rails.root, 'lib', 'demo_data', 'demo_seeds', "#{seed}.rb")
end
