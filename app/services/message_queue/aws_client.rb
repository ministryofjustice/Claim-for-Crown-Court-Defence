module MessageQueue
  class AwsClient
    def initialize(queue)
      @sqs = Aws::SQS::Client.new(access_key_id: Settings.aws.access, secret_access_key: Settings.aws.secret)
      begin
        @queue_url = @sqs.get_queue_url(queue_name: queue).queue_url
      rescue Aws::SQS::Errors::NonExistentQueue
        raise StandardError.new, "Non existing queue: #{queue}."
      end
    end

    def send!(message)
      @sqs.send_message(
        queue_url: @queue_url,
        message_body: message[:body],
        message_attributes: message[:attributes]
      )
      true
    end

    def poll!
      resp = @sqs.receive_message(
        queue_url: @queue_url,
        max_number_of_messages: Settings.aws.poll_message_count,
        wait_time_seconds: Settings.aws.poll_message_wait_time
      )
      resp.messages.each do |m|
        irs = InjectionResponseService.new(JSON.parse(m.body))
        if irs.run! && %w[demo production].include?(ENV['ENV'])
          @sqs.delete_message(queue_url: @queue_url, receipt_handle: m.receipt_handle)
        end
      end
    end
  end
end
