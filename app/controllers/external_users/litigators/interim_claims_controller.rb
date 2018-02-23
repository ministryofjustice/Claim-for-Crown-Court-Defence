class ExternalUsers::Litigators::InterimClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::InterimClaim

  private

  def build_nested_resources
    @claim.build_interim_fee if @claim.interim_fee.nil?
    @claim.build_warrant_fee if @claim.warrant_fee.nil?

    %i[disbursements expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end

  def claim_action_path(options)
    edit_litigators_interim_claim_path(@claim, step: options[:step])
  end
end
