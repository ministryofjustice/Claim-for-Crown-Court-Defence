Dir[File.join(Rails.root, 'lib', 'messaging', '*.rb')].each { |file| require file }

Messaging::Producer.client_class = Aws::SNS::Client if Rails.env.production?
