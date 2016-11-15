module Messaging
  class SOAPMessage
    attr_accessor :errors

    WSA_FROM = 'http://cob.gov.uk/cccd'.freeze
    WSA_TO = 'http://legalaid.gov.uk/infoX/gateway/ccr'.freeze
    CBO_NS = %w(cbo http://www.justice.gov.uk/2016/11/cbo).freeze

    def payload_schema
      raise 'not implemented'
    end

    def action
      raise 'not implemented'
    end

    def root
      raise 'not implemented'
    end

    def message_id
      raise 'not implemented'
    end

    def message_content
      raise 'not implemented'
    end

    def to_xml
      build_envelope { payload_message }.to_xml
    end

    def valid?
      errors.clear
      xsd = Nokogiri::XML::Schema(File.open(payload_schema))
      xsd.validate(request_message).each { |error| errors << error.message }
      errors.empty?
    end

    def errors
      @errors ||= []
    end

    private

    def must_understand
      {'soapenv:mustUnderstand': '1'}.freeze
    end

    def build_envelope
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
        builder[:soapenv].Envelope('xmlns:soapenv': 'http://www.w3.org/2003/05/soap-envelope') {
          builder[:soapenv].Header('xmlns:wsa': 'http://www.w3.org/2005/08/addressing') {
            builder[:wsa].Action(must_understand, action)
            builder[:wsa].From(must_understand) { builder[:wsa].Address(WSA_FROM) }
            builder[:wsa].MessageID(must_understand, message_id)
            builder[:wsa].To(must_understand, WSA_TO)
          }
          builder[:soapenv].Body {
            builder << yield
          }
        }
      end
    end

    def payload_message
      @payload_message ||= begin
        doc = Nokogiri::XML(message_content.to_xml(xml_options))
        doc.root.add_namespace_definition(*CBO_NS)
        doc.root.to_xml
      end
    end

    def request_message
      xml = Nokogiri::XML::Document.parse(to_xml)
      Nokogiri::XML::Document.parse(xml.xpath('//soapenv:Body').children.to_xml)
    end

    def xml_options
      {dasherize: false, skip_types: true, skip_instruct: true, skip_nils: true, root: root}.freeze
    end
  end
end
