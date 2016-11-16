module Messaging
  class MockClient
    def initialize(*)
    end

    def method_missing(method, *args)
      self.class.queue.push(method => args)
      build_response(self.class.queue.last)
    end

    def self.queue
      @@queue ||= Array.new
    end

    private

    def build_response(res)
      Messaging::ProducerResponse.new(code: 200, body: res, description: 'ok')
    end
  end
end
