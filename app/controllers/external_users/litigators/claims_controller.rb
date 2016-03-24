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

   def update
    update_source_for_api
    if @claim.update(claim_params)
      @claim.documents.each { |d| d.update_column(:external_user_id, @claim.external_user_id) }
      submit_if_required_and_redirect
    else
      present_errors
      render_edit_with_resources
    end
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
