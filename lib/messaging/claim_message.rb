module Messaging
  class ClaimMessage
    cattr_accessor :producer
    attr_accessor :claim

    def initialize(claim)
      self.claim = claim
    end

    def publish
      self.class.producer.publish(message)
    end

    def message
      Messaging::SOAPMessage.new(claim).to_xml
    end
  end
end
