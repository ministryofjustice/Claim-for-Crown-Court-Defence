module Messaging
  class MockClient
    attr_accessor :config

    def initialize(config = {})
      self.config = config
    end

    def publish(payload)
      self.class.queue.push(payload)
      payload
    end

    def self.queue
      @@queue ||= Array.new
    end
  end
end
