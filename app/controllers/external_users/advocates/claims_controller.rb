class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::AdvocateClaim.new
    load_offences_and_case_types
    build_nested_resources
  end

  def create
    @claim = Claim::AdvocateClaim.new(params_with_external_user_and_creator)
    if submitting_to_laa?
      create_and_submit
    else
      create_draft
    end
  end

private

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:external_user_id, claim.external_user_id) }
  end

end
