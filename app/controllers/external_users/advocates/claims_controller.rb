class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::AdvocateClaim.new
    super
  end

  def create
    @claim = Claim::AdvocateClaim.new(params_with_external_user_and_creator)
    super
  end

private

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:external_user_id, claim.external_user_id) }
  end

  def load_external_users_in_provider
    @advocates_in_provider = @provider.advocates if @external_user.admin?
  end

  def build_nested_resources
    @claim.fixed_fees.build if @claim.fixed_fees.none?
    super
  end
end
