class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource
  before_action :set_form_step, only: %i[new create edit update]

  def new
    @claim = Claim::AdvocateClaim.new
    super
  end

  def create
    @claim = Claim::AdvocateClaim.new(params_with_external_user_and_creator)
    super
  end

  private

  def set_form_step
    # TODO: refactor so it manages step based on it being valid
    # redirecting to the summary page or the claims page if isn't
    params[:claim][:form_step] = :basic_and_fixed_fees if params.dig(:claim, :form_step) == 'fees'
  end

  def build_nested_resources
    @claim.fixed_fees.build if @claim.fixed_fees.none?

    %i[misc_fees expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
