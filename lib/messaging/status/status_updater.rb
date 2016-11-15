module Messaging
  module Status
    class StatusUpdater
      cattr_accessor :client_class
      attr_accessor :batch_limit

      MAX_RETRIES = 3

      def initialize(batch_limit: 1)
        self.batch_limit = batch_limit
      end

      def run
        return unless pending_claims.any?
        process_response(client.post(payload))
      end

      def payload
        Messaging::Status::StatusRequest.new(pending_claim_uuids).to_xml
      end

      def client
        Messaging::HttpProducer.new(:claim_status, client_class: client_class)
      end

      private

      def pending_claims
        @pending_claim ||= ExportedClaim.pending.where { retries < MAX_RETRIES }.limit(batch_limit).to_a
      end

      def pending_claim_uuids
        ids = pending_claims.map(&:id)
        uuids = pending_claims.map(&:claim_uuid)
        update_records!(ids)
        uuids
      end

      def update_records!(ids)
        ExportedClaim.where(id: ids).update_all(last_request_at: 'now()', updated_at: 'now()')
        ExportedClaim.update_counters(ids, retries: 1)
      end

      # TODO: decide what to store and when we assume not to query again for this same claim
      def process_response(xml)
        response = Messaging::Status::StatusResponse.new(xml)
        ExportedClaim.find_by!(claim_uuid: response.claim_uuid).update_attributes(status: response.status)
      end

      def client_class
        self.class.client_class || RestClient::Resource
      end
    end
  end
end
