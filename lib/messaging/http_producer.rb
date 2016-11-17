module Messaging
  class HttpProducer
    attr_accessor :client, :config_name

    def initialize(config_name, client_class:)
      self.config_name = config_name
      self.client = client_class.new(endpoint, client_config)
    end

    def publish(payload)
      Rails.logger.info "[Client: #{client.class.name}] Posting payload: #{payload}"
      build_response do_post(payload)
    end
    alias post publish

    private

    # TODO: the producers could extract this and other common methods to a superclass, TBC.
    def do_post(payload, format = :xml)
      client.post(payload, content_type: format)
    rescue RestClient::ExceptionWithResponse => ex
      ex.response
    end

    # TODO: the producers could extract this and other common methods to a superclass, TBC.
    def build_response(res)
      return Messaging::ProducerResponse.no_response if res.nil?
      Messaging::ProducerResponse.new(code: res.code, body: res.body, description: res.description)
    end

    def endpoint
      config.fetch(:endpoint)
    end

    def client_config
      config.fetch(:client_config).symbolize_keys!
    end

    def config
      @config ||= Rails.application.config_for(config_name).symbolize_keys!
    end
  end
end
