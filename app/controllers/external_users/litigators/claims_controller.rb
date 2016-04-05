class ExternalUsers::Litigators::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::LitigatorClaim.new
    super
  end

  def create
    @claim = Claim::LitigatorClaim.new(params_with_external_user_and_creator)
    super
  end

private

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:creator_id, claim.creator_id) }
  end

  def load_external_users_in_provider
    @litigators_in_provider = @provider.litigators if @external_user.admin?
  end
end
