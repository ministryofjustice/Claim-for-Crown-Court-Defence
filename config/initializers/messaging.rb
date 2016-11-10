Dir[File.join(Rails.root, 'lib', 'messaging', '*.rb')].each { |file| require file }

# If you want to use Amazon SNS:
# client_class = Rails.env.production? ? Aws::SNS::Client : Messaging::MockClient
# Messaging::ClaimMessage.producer = Messaging::SNSProducer.new(client_class: client_class, queue: 'cccd-claims')

# If you want to use HTTP Post:
client_class = Rails.env.production? ? RestClient::Resource : Messaging::MockClient
Messaging::ClaimMessage.producer = Messaging::HttpProducer.new(client_class: client_class)
