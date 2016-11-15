module Messaging
  class MessageValidationError < StandardError; end

  class ClaimMessage
    cattr_accessor :producer
    attr_accessor :claim

    def initialize(claim)
      self.claim = claim
    end

    def publish
      raise MessageValidationError.new(message.errors) unless valid_message?
      self.class.producer.publish(payload)
      create_exported_claim
    end

    def payload
      message.to_xml
    end

    private

    def message
      @message ||= Messaging::ExportMessage.new(claim)
    end

    def valid_message?
      message.valid?
    end

    def create_exported_claim
      ExportedClaim.new(claim_id: claim.id, claim_uuid: claim.uuid).save
    end
  end
end
