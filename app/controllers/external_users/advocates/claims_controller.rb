class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  def new
    @claim = Claim::AdvocateClaim.new
    super
  end

  def create
    @claim = Claim::AdvocateClaim.new(params_with_external_user_and_creator)
    super
  end

  private

  def build_nested_resources
    @claim.fixed_fees.build if @claim.fixed_fees.none?

    %i[misc_fees expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
