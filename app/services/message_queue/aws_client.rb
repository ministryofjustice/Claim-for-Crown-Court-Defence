module MessageQueue
  class AwsClient
    def initialize(queue)
      @sqs = Aws::SQS::Client.new(region: Settings.aws.region)
      begin
        @queue_url = queue_url(queue)
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
      messages.each do |m|
        irs = InjectionResponseService.new(JSON.parse(m.body))
        delete_message(m.receipt_handle) if irs.run!
      end
    end

    private

    def queue_url(queue)
      return queue if queue.match?(valid_web_url_regex)
      @sqs.get_queue_url(queue_name: queue).queue_url
    end

    def valid_web_url_regex
      /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/
    end

    def messages
      @sqs.receive_message(
        queue_url: @queue_url,
        max_number_of_messages: Settings.aws.poll_message_count,
        wait_time_seconds: Settings.aws.poll_message_wait_time
      ).messages
    end

    def delete_message(receipt_handle)
      @sqs.delete_message(queue_url: @queue_url, receipt_handle:)
    end
  end
end
