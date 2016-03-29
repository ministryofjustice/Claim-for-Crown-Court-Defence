class ExternalUsers::Litigators::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::LitigatorClaim.new
    load_offences_and_case_types
    build_nested_resources
  end

  def create
    @claim = Claim::LitigatorClaim.new(params_with_creator)
    if submitting_to_laa?
      create_and_submit
    else
      create_draft
    end
  end

  def edit
    build_nested_resources
    load_offences_and_case_types
    @disable_assessment_input = true
    redirect_to external_users_claims_url, notice: 'Can only edit "draft" claims' unless @claim.editable?
  end

private

  def params_with_creator
    form_params = claim_params
    form_params[:creator_id] = @external_user.id
    form_params
  end

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:creator_id, claim.creator_id) }
  end

end
