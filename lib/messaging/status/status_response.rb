module Messaging
  module Status
    class StatusResponse
      attr_accessor :response, :ack_id, :claim_uuid, :processing_result, :errors

      def initialize(response)
        self.response = response
      end

      def ack_id
        @ack_id ||= document.at_xpath('//ack_id')&.content
      end

      def claim_uuid
        @claim_uuid ||= document.at_xpath('//claim_details/uuid')&.content
      end

      def processing_result
        @processing_result ||= document.at_xpath('//processing_result/success')&.content.to_s.to_bool
      end

      def errors
        @errors ||= errors_content.map do |error|
          { code: error.at_xpath('code').content.to_i, detail: error.at_xpath('detail').content }
        end
      end

      def status
        processing_result ? 'success' : 'error'
      end

      private

      def errors_content
        document.xpath('//processing_result/errors/*')
      rescue
        []
      end

      def document
        @document ||= Nokogiri::XML(response)
      end
    end
  end
end
