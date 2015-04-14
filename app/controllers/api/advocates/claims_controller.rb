module Api
  module Advocates
    class ClaimsController < ::Advocates::ClaimsController
      respond_to :json

      def create
        @claim = Claim.new(claim_params.merge(advocate_id: current_user.id))

        if @claim.save
          @claim.submit!
          render json: @claim, message: 'Claim successfully submitted', status: :created
        else
          render json: { errors: @claim.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @claim.update(claim_params)
          render json: @claim, message: 'Claim sucessfully updated'
        else
          render json: { errors: @claim.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @claim.destroy
        render json: { message: 'Claim successfully deleted' }, status: :ok
      end

    end
  end
end