require_relative 'soap_message'

module Messaging
  class ExportMessage < Messaging::SOAPMessage
    attr_accessor :claim, :message_uuid

    def initialize(claim, _options = {})
      self.claim = claim
      self.message_uuid = SecureRandom.uuid
    end

    def payload_schema
      File.join(Rails.root, 'config', 'schemas', 'claim_request.xsd').freeze
    end

    def action
      'newCBOClaim'.freeze
    end

    def root
      'cbo:claim_request'.freeze
    end

    def message_id
      'uuid:%s' % message_uuid
    end

    def message_content
      API::Entities::FullClaim.represent(claim)
    end
  end
end
