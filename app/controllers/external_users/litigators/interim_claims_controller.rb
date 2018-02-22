class ExternalUsers::Litigators::InterimClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  def new
    @claim = Claim::InterimClaim.new
    super
  end

  def create
    @claim = Claim::InterimClaim.new(params_with_external_user_and_creator)
    super
  end

  private

  def build_nested_resources
    @claim.build_interim_fee if @claim.interim_fee.nil?
    @claim.build_warrant_fee if @claim.warrant_fee.nil?

    %i[disbursements expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
