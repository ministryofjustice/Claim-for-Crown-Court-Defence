module Messaging
  module Status
    class StatusUpdater
      cattr_accessor :client_class
      attr_accessor :batch_limit, :uuids

      MAX_RETRIES = 3

      def initialize(options = {})
        self.batch_limit = options.fetch(:batch_limit, 1)
        self.uuids = options.fetch(:uuids, [])
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
        @pending_claim ||= begin
          if uuids.any?
            ExportedClaim.where(claim_uuid: uuids)
          else
            ExportedClaim.pending.where { retries < MAX_RETRIES }
          end.limit(batch_limit).to_a
        end
      end

      def pending_claim_uuids
        ids = pending_claims.map(&:id)
        uuids = pending_claims.map(&:claim_uuid)
        update_records!(ids)
        uuids
      end

      def update_records!(ids)
        ExportedClaim.where(id: ids).update_all(retried_at: 'now()', updated_at: 'now()')
        ExportedClaim.update_counters(ids, retries: 1)
      end

      # TODO: decide what to store and when we assume not to query again for this same claim
      def process_response(res)
        if res.error?
          Rails.logger.error "[StatusUpdater] Response code: #{res.code} - Response body: #{res.body}"
        else
          response = Messaging::Status::StatusResponse.new(res.body)
          ExportedClaim.find_by!(claim_uuid: response.claim_uuid).update_attributes(status: response.status)
        end
      end

      def client_class
        self.class.client_class || RestClient::Resource
      end
    end
  end
end
