Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  puts "Seeding '#{seed}'..."
  load seed
end
