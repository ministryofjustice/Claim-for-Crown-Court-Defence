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
      process_response(self.class.producer.publish(payload))
    end

    def payload
      message.to_xml
    end

    private

    def message
      @message ||= Messaging::ExportRequest.new(claim)
    end

    def valid_message?
      message.valid?
    end

    def process_response(res)
      attrs = if res.success?
                response = Messaging::ExportResponse.new(res.body)
                {status: response.status, status_code: nil, status_msg: response.error_message, published_at: 'now()'}
              else
                # TODO: do we receive a SOAP message with errors here too?
                {status: 'publish_error', status_code: res.code, status_msg: res.description, published_at: nil}
              end
      ExportedClaim.where(claim_id: claim.id).update_all(attrs)
    end
  end
end
