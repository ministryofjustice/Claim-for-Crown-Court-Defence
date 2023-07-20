class ExternalUsers::Fees::PricesController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource
  before_action :set_claim, only: %i[calculate]

  attr_reader :claim

  ALLOWABLE_PRICER_TYPES = %w[UnitPrice GraduatedPrice].freeze

  def calculate
    calculator = pricer.new(claim, calculator_params.except(:id))
    response = calculator.call
    respond_to do |format|
      format.html
      format.json do
        render json: response, status: response.success? ? 200 : 422
      end
    end
  end

  private

  def pricer
    return unless calculator_params[:price_type].in?(ALLOWABLE_PRICER_TYPES)
    "Claims::FeeCalculator::#{calculator_params[:price_type]}".constantize
  end

  def set_claim
    @claim = Claim::BaseClaim.active.find_by(id: calculator_params[:claim_id])
  end

  def calculator_params
    params.permit(
      :format,
      :id,
      :price_type,
      :claim_id,
      :fee_type_id,
      :advocate_category,
      :ppe,
      :pw,
      :days,
      :pages_of_prosecuting_evidence,
      fees: %i[fee_type_id quantity]
    )
  end
end
