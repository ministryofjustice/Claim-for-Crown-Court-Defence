module Messaging
  class ExportResponse
    attr_accessor :response, :ack_id, :claim_uuid, :error_code, :error_message

    def initialize(response)
      self.response = response
    end

    def success?
      claim_uuid.present?
    end

    def error?
      !success?
    end

    def status
      return 'published' if success?
      error_code || 'unknown_error'
    end

    def ack_id
      @ack_id ||= body&.at_xpath('AckId')&.content
    end

    def claim_uuid
      @claim_uuid ||= body&.at_xpath('ClaimUUID')&.content
    end

    def error_code
      @error_code ||= body&.at_xpath('faultcode')&.content
    end

    def error_message
      @error_message ||= body&.at_xpath('faultstring')&.content
    end

    private

    def body
      document.at_xpath('//SOAP-ENV:Body/ClaimResponse') || document.at_xpath('//SOAP-ENV:Body/SOAP-ENV:Fault')
    rescue
      nil
    end

    def document
      @document ||= Nokogiri::XML(response)
    end
  end
end
