module Messaging
  class ClaimMessage
    attr_accessor :claim

    def initialize(claim)
      self.claim = claim
    end

    def publish
      Messaging::Producer.new(queue: 'cccd-claims').publish(payload)
    end

    def payload
      {subject: subject, message: message}
    end

    # Subjects must be ASCII text that begins with a letter, number, or punctuation mark
    # Must not include line breaks or control characters and be less than 100 characters long
    #
    def subject
      'Claim UUID %s' % claim.uuid
    end

    # Messages must be UTF-8 encoded strings at most 256 KB in size
    #
    def message
      API::Entities::FullClaim.represent(claim).to_xml(xml_options)
    end

    private

    def xml_options
      {dasherize: false, skip_types: true, root: 'claim'}
    end
  end
end
