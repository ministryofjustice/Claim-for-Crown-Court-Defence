class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::AdvocateClaim

  private

  def build_nested_resources
    @claim.build_interim_claim_info if @claim.interim_claim_info.nil?

    build_fixed_fees if @claim.fixed_fee_case?

    %i[misc_fees expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end

  def build_fixed_fees
    # NOTE: the `reload` is !important. prevents duplicate fees being created during error flows
    existing_fixed_fee_fee_type_ids = @claim.fixed_fees.reload.map(&:fee_type_id)

    @claim.eligible_fixed_fee_types.each do |eligible_fee_type|
      next if existing_fixed_fee_fee_type_ids.include?(eligible_fee_type.id)
      @claim.fixed_fees.build(fee_type_id: eligible_fee_type.id)
    end
  end
end
