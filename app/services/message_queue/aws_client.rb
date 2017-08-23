module MessageQueue
  class AwsClient
    def initialize(message, to_queue)
      @sqs = Aws::SQS::Client.new(access_key_id: Settings.aws.access, secret_access_key: Settings.aws.secret)
      @message = message
      begin
        @queue_url = @sqs.get_queue_url(queue_name: to_queue).queue_url
      rescue Aws::SQS::Errors::NonExistentQueue
        raise StandardError.new, "Non existing queue: #{to_queue}."
      end
    end

    def send_message!
      @sqs.send_message(
        queue_url: @queue_url,
        message_body: @message[:body],
        message_attributes: @message[:attributes]
      )
      true
    end
  end

  class MessageTemplate
    def self.claim_created(type, uuid)
      {
        body: 'Claim added',
        attributes:
          {
            'type':
              {
                data_type: 'String',
                string_value: type
              },
            'uuid':
              {
                data_type: 'String',
                string_value: uuid
              }
          }
      }
    end
  end
end
