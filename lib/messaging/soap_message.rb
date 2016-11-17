module Messaging
  class SOAPMessage
    attr_accessor :errors

    ENV_SCHEMA = 'http://www.w3.org/2003/05/soap-envelope'.freeze
    ADDRESSING = 'http://www.w3.org/2005/08/addressing'.freeze

    WSA_FROM = 'http://cob.gov.uk/cccd'.freeze
    WSA_TO = 'http://legalaid.gov.uk/infoX/gateway/ccr'.freeze
    CBO_NS = %w(cbo http://www.justice.gov.uk/2016/11/cbo).freeze

    DEFAULT_FORMAT = Nokogiri::XML::Node::SaveOptions::FORMAT +
        Nokogiri::XML::Node::SaveOptions::NO_DECLARATION +
        Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS

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
      build_envelope { payload_message }.to_xml(builder_xml_options)
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
      {'env:mustUnderstand': '1'}.freeze
    end

    def build_envelope
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
        builder[:env].Envelope('xmlns:env': ENV_SCHEMA) {
          builder[:env].Header('xmlns:wsa': ADDRESSING) {
            builder[:wsa].To(must_understand, WSA_TO)
            builder[:wsa].From(must_understand) { builder[:wsa].Address(WSA_FROM) }
            builder[:wsa].Action(action)
            builder[:wsa].MessageID(message_id)
          }
          builder[:env].Body {
            builder << yield
          }
        }
      end
    end

    def payload_message
      @payload_message ||= begin
        doc = Nokogiri::XML(message_content.to_xml(payload_xml_options))
        doc.root.add_namespace_definition(*CBO_NS)
        doc.to_xml(builder_xml_options)
      end
    end

    def request_message
      xml = Nokogiri::XML::Document.parse(to_xml)
      Nokogiri::XML::Document.parse(xml.xpath('//env:Body').children.to_xml)
    end

    def payload_xml_options
      {dasherize: false, skip_types: true, skip_instruct: true, skip_nils: true, root: root}.freeze
    end

    def builder_xml_options
      {save_with: DEFAULT_FORMAT}
    end
  end
end
