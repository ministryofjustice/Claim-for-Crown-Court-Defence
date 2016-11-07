module Messaging
  class SOAPMessage
    attr_accessor :claim, :message_uuid

    WSA_ACTION = 'newCBOClaim'.freeze
    WSA_FROM = 'http://cob.gov.uk/cccd'.freeze
    WSA_TO = 'http://legalaid.gov.uk/infoX/gateway/ccr'.freeze

    def initialize(claim)
      self.claim = claim
      self.message_uuid = SecureRandom.uuid
    end

    def to_xml
      build_envelope do
        API::Entities::FullClaim.represent(claim).to_xml(xml_options)
      end
    end

    private

    def must_understand
      {'soapenv:mustUnderstand': '1'}
    end

    def message_id
      'uuid:%s' % message_uuid
    end

    def build_envelope
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
        builder[:soapenv].Envelope('xmlns:soapenv': 'http://www.w3.org/2003/05/soap-envelope', 'xmlns:cbo': 'http://www.justice.gov.uk/2016/11/cbo') {
          builder[:soapenv].Header('xmlns:wsa': 'http://www.w3.org/2005/08/addressing') {
            builder[:wsa].Action(must_understand, WSA_ACTION)
            builder[:wsa].From(must_understand) { builder[:wsa].Address(WSA_FROM) }
            builder[:wsa].MessageID(must_understand, message_id)
            builder[:wsa].To(must_understand, WSA_TO)
          }
          builder[:soapenv].Body {
            builder << yield
          }
        }
      end.to_xml
    end

    def xml_options
      {dasherize: false, skip_types: true, skip_instruct: true, root: 'cbo:ClaimRequest'}
    end
  end
end
