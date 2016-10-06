class ClaimExporter

  def initialize(claim)
    @claim = claim
  end

  def to_hash
    {
      claim: {
        claim_details: {
          uuid: @claim.uuid,
          type: @claim.pretty_type,
          provider_code: @claim.supplier_number,
          created_by: {
            first_name: @claim.creator.first_name,
            last_name: @claim.creator.last_name,
            email: @claim.creator.email
          },
          external_user: {
            first_name: @claim.external_user.first_name,
            last_name: @claim.external_user.last_name,
            email: @claim.external_user.email
          },

        }
      }
    }
  end
end