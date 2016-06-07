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

  def load_external_users_in_provider
    @litigators_in_provider = @provider.litigators if @external_user.admin?
  end

  def build_nested_resources
    @claim.build_graduated_fee if @claim.graduated_fee.nil?
    @claim.build_warrant_fee if @claim.warrant_fee.nil?
    @claim.build_fixed_fee if @claim.fixed_fee.nil?

    [:misc_fees, :disbursements, :expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
