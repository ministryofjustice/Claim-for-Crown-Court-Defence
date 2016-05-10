class ExternalUsers::Litigators::TransferClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::TransferClaim.new
    super
  end

  def create
    @claim = Claim::TransferClaim.new(params_with_external_user_and_creator)
    super
  end

private

  def update_claim_document_owners(claim)
    claim.documents.each { |d| d.update_column(:creator_id, claim.creator_id) }
  end

  def load_external_users_in_provider
    @litigators_in_provider = @provider.litigators if @external_user.admin?
  end

  def build_nested_resources
    @claim.build_transfer_detail if @claim.transfer_detail.nil?
    @claim.build_transfer_fee    if @claim.transfer_fee.nil?

    [:misc_fees, :disbursements].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
