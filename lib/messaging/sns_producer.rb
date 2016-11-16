module Messaging
  class SNSProducer
    attr_accessor :client, :queue

    def initialize(client_class:, queue:)
      self.client = client_class.new
      self.queue = queue
      raise ArgumentError, "Queue `#{queue}` not found" unless queue_present?
    end

    def publish(payload)
      Rails.logger.info "[Client: #{client.class.name}] [ARN: #{target_arn}] Publishing payload: #{payload}"
      build_response client.publish(target_arn: target_arn, subject: 'Claim', message: payload)
    end

    def queue_name
      [queue, host].join('-')
    end

    def target_arn
      [config.fetch(:sns_arn), queue_name].join(':')
    end

    private

    # TODO: check what attributes SNS actually returns to retrieve the code and description, if any
    # TODO: also, the producers could extract this and other common methods to a superclass, TBC.
    def build_response(res)
      Messaging::ProducerResponse.new(code: res.code, body: res, description: res.description)
    end

    def host
      Rails.host.env || 'local'
    end

    def queue_present?
      config.fetch(:queues).include?(queue)
    end

    def client_config
      config.fetch(:client_config).symbolize_keys!
    end

    def config
      @config ||= Rails.application.config_for(:aws_queues).symbolize_keys!
    end
  end
end
