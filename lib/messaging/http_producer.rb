module Messaging
  class HttpProducer
    attr_accessor :client, :config_name

    def initialize(config_name, client_class:)
      self.config_name = config_name
      self.client = client_class.new(endpoint, client_config)
    end

    def publish(payload)
      Rails.logger.info "[Client: #{client.class.name}] Posting payload: #{payload}"
      client.post(payload, content_type: :xml)
    end
    alias post publish

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
