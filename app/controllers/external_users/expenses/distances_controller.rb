module ExternalUsers
  module Expenses
    class DistancesController < ExternalUsers::ApplicationController
      skip_load_and_authorize_resource
      before_action :set_claim, only: %i[create]

      def create
        result = DistanceCalculatorService.call(@claim, distance_params)
        respond_to do |format|
          format.json do
            if result.error.present?
              render json: { error: t(".errors.#{result.error}") }, status: :unprocessable_entity
            else
              render json: { distance: result.value }
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
  end
end
