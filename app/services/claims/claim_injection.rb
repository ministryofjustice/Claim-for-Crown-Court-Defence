module Claims
  class ClaimInjection
    attr_accessor :claim

    def initialize(claim)
      self.claim = claim
    end

    def execute
      PublishClaimJob.perform_later(claim)
      find_or_create_exported_record
    end

    private

    def find_or_create_exported_record
      ExportedClaim.find_or_create_by(claim_id: claim.id, claim_uuid: claim.uuid).update_attributes(default_attrs)
    end

    def default_attrs
      {status: 'enqueued', status_code: nil, status_msg: nil, retries: 0, retried_at: nil, published_at: nil}
    end
  end
end
