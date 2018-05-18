class ExternalUsers::Litigators::ClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::LitigatorClaim

  private

  def build_nested_resources
    @claim.build_graduated_fee if @claim.graduated_fee.nil?
    @claim.build_warrant_fee if @claim.warrant_fee.nil?
    @claim.build_fixed_fee if @claim.fixed_fee.nil?
    @claim.build_interim_claim_info if @claim.interim_claim_info.nil?

    %i[misc_fees disbursements expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
