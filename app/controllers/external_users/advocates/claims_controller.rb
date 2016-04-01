class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::AdvocateClaim.new
    super
  end

  def create
    @claim = Claim::AdvocateClaim.new(params_with_advocate_and_creator)
    super
  end

private

  def params_with_advocate_and_creator
    form_params = claim_params
    form_params[:external_user_id] = @external_user.id unless @external_user.admin?
    form_params[:creator_id] = @external_user.id
    form_params
  end

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:external_user_id, claim.external_user_id) }
  end

  def load_external_users_in_provider
    @advocates_in_provider = @provider.advocates if @external_user.admin?
  end
end
