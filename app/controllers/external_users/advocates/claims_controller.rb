class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  before_action :load_advocates_in_provider, only: [:new, :edit, :create, :update]

  def new
    @claim = Claim::AdvocateClaim.new
    load_offences_and_case_types
    build_nested_resources
  end

  def create
    @claim = Claim::AdvocateClaim.new(params_with_advocate_and_creator)
    if submitting_to_laa?
      create_and_submit
    else
      create_draft
    end
  end

private

  def load_advocates_in_provider
    @advocates_in_provider = @provider.advocates if @external_user.admin? && self.class == ExternalUsers::Advocates::ClaimsController
  end

def params_with_advocate_and_creator
    form_params = claim_params
    form_params[:external_user_id] = @external_user.id unless @external_user.admin?
    form_params[:creator_id] = @external_user.id
    form_params
  end

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:external_user_id, claim.external_user_id) }
  end

end
