Dir[Rails.root.join('lib/rule/**/*.rb')].sort.each { |f| require f }
