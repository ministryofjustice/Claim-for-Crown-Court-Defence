class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::AdvocateClaim

  private

  def build_nested_resources
    @claim.fixed_fees.build if @claim.fixed_fees.none?

    %i[misc_fees expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
