Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |seed|
  puts "Seeding '#{seed}'..."
  load seed
end
