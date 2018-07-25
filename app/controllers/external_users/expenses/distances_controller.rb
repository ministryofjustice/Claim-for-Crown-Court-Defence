class ExternalUsers::Expenses::DistancesController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource
  before_action :set_claim, only: %i[create]

  def create
    result = ::Expenses::TravelDistanceCalculator.call(@claim, distance_params)
    respond_to do |format|
      format.json do
        if result.success?
          render json: { distance: result.value! }
        else
          render json: { error: t(".errors.#{result.failure}") }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_claim
    @claim = Claim::BaseClaim.active.find_by(id: params[:claim_id])
  end

  def distance_params
    params.permit(:destination)
  end
end
