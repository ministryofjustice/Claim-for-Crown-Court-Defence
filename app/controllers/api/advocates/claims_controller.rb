module Api
  module Advocates
    class ClaimsController < ::Advocates::ClaimsController
      respond_to :json

      def update
        if @claim.update(claim_params)
          render json: @claim, message: 'Claim sucessfully updated'
        else
          render json: { errors: @claim.errors.full_messages }, status: :unprocessable_entity
        end
      end

    end
  end
end