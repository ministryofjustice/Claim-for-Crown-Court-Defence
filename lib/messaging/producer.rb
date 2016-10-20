module Messaging
  class Producer
    cattr_accessor :client_class
    attr_accessor :client, :queue

    def self.client_class
      @@client_class ||= Messaging::MockClient
    end

    def initialize(queue:)
      self.client = self.class.client_class.new(client_config)
      self.queue = queue
      raise ArgumentError, "Queue `#{queue}` not found" unless queue_present?
    end

    def publish(payload)
      Rails.logger.info "[Client: #{self.class.client_class.name}] [ARN: #{target_arn}] Publishing payload: #{payload}"
      client.publish({target_arn: target_arn}.merge(payload))
    end

    def queue_name
      [queue, host].join('-')
    end

    def target_arn
      [config.fetch(:sns_arn), queue_name].join(':')
    end

    private

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
