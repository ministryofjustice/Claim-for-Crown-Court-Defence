require_relative '../soap_message'

module Messaging
  module Status
    class StatusRequest < Messaging::SOAPMessage
      attr_accessor :uuids, :message_uuid

      def initialize(uuids, _options = {})
        self.uuids = uuids
        self.message_uuid = SecureRandom.uuid
      end

      def payload_schema
        File.join(Rails.root, 'config', 'schemas', 'claim_status.xsd').freeze
      end

      # TODO: we need to confirm this
      def action
        'statusRequest'.freeze
      end

      # TODO: we need to confirm this
      def root
        'cbo:status_request'.freeze
      end

      # TODO: not sure we need a sequence/id/uuid here, we might omit it
      def message_id
        'uuid:%s' % message_uuid
      end

      # TODO: we need to confirm this
      def message_content
        { 'ClaimUUIDs': uuids }
      end
    end
  end
end
