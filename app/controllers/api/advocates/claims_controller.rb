module Api
  module Advocates

    class ClaimsController < ActionController::Base
      include Flip::ControllerFilters
      require_feature :api #404 is returned when something hits this controller, but the feature is switched off
      protect_from_forgery with: :null_session
      http_basic_authenticate_with name: ENV['ADP_API_USER'], password: ENV['ADP_API_PASS']
      respond_to :json

      def create
        @claim = Claim.new(claim_params)

        begin
          @claim.submit!
          @claim.save
          render json: @claim, status: :created
        rescue
          render json: { errors: @claim.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def claim_params
        params.require(:claim).permit(
         :advocate_id,
         :creator_id,
         :court_id,
         :scheme_id,
         :case_number,
         :case_type,
         :offence_id,
         :advocate_category,
         :additional_information,
         :apply_vat,
         :prosecuting_authority,
         :indictment_number,
         defendants_attributes: [:id, :claim_id, :first_name, :middle_name, :last_name, :date_of_birth, :representation_order_date, :order_for_judicial_apportionment, :maat_reference, :_destroy],
         fees_attributes: [:id, :claim_id, :fee_id, :quantity, :rate, :amount, :_destroy],
         expenses_attributes: [:id, :claim_id, :expense_type_id, :quantity, :rate, :amount, :_destroy],
         documents_attributes: [:id, :claim_id, :document, :description]
         )
        end
    end
  end
end