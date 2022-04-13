Dir[Rails.root.join('lib', 'rule', '**', '*.rb')].each { |f| require f }
