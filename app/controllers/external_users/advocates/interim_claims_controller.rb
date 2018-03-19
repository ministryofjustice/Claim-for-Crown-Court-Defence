class ExternalUsers::Advocates::InterimClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::AdvocateInterimClaim

  def build_nested_resources
    @claim.build_warrant_fee if @claim.warrant_fee.nil?

    %i[expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
