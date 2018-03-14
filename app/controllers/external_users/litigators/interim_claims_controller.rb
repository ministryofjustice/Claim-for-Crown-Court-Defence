class ExternalUsers::Litigators::InterimClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::InterimClaim

  private

  def build_nested_resources
    @claim.build_interim_fee if @claim.interim_fee.nil?
    @claim.build_warrant_fee if @claim.warrant_fee.nil?

    [:disbursements].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
