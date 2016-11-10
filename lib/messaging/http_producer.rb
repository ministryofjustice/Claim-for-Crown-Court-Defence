module Messaging
  class HttpProducer
    attr_accessor :client

    def initialize(client_class:)
      self.client = client_class.new(endpoint, client_config)
    end

    def publish(payload)
      Rails.logger.info "[Client: #{client.class.name}] Publishing payload: #{payload}"
      client.post(payload, content_type: :xml)
    end

    private

    def endpoint
      config.fetch(:endpoint)
    end

    def client_config
      config.fetch(:client_config).symbolize_keys!
    end

    def config
      @config ||= Rails.application.config_for(:claim_request).symbolize_keys!
    end
  end
end
