class ExternalUsers::Advocates::HardshipClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::AdvocateHardshipClaim

  private

  def build_nested_resources
    @claim.build_interim_claim_info if @claim.interim_claim_info.nil?

    %i[misc_fees expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
