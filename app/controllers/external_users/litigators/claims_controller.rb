class ExternalUsers::Litigators::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::LitigatorClaim.new
    load_offences_and_case_types
    build_nested_resources
  end

  def create
    @claim = Claim::LitigatorClaim.new(params_with_external_user_and_creator)
    if submitting_to_laa?
      create_and_submit
    else
      create_draft
    end
  end

private

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:creator_id, claim.creator_id) }
  end

end
