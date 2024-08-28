module ExternalUsers
  module Fees
    class PricesController < ExternalUsers::ApplicationController
      skip_load_and_authorize_resource
      before_action :set_claim, only: %i[calculate]

      attr_reader :claim

      ALLOWABLE_PRICER_TYPES = {
        'UnitPrice' => Claims::FeeCalculator::UnitPrice,
        'GraduatedPrice' => Claims::FeeCalculator::GraduatedPrice
      }.freeze

      def calculate
        calculator = pricer.new(claim, calculator_params.except(:id))
        response = calculator.call
        respond_to do |format|
          format.html
          format.json do
            render json: response, status: response.success? ? :ok : :unprocessable_entity
          end
        end
      end

      private

      def pricer
        ALLOWABLE_PRICER_TYPES.fetch(calculator_params[:price_type], Claims::FeeCalculator::NullPrice)
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
          :london_rates_apply,
          :ppe,
          :pw,
          :days,
          :pages_of_prosecuting_evidence,
          fees: %i[fee_type_id quantity]
        )
      end
    end
  end
end
