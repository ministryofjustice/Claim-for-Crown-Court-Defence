module Messaging
  class MockClient
    def initialize(*)
    end

    def method_missing(method, *args)
      self.class.queue.push(method => args)
      self.class.queue.last
    end

    def self.queue
      @@queue ||= Array.new
    end
  end
end
