module Api
  module Advocates

    class ClaimsController < ActionController::Base
      protect_from_forgery with: :null_session
      http_basic_authenticate_with name: ENV['CBO_API_USER'], password: ENV['CBO_API_PASS']
      respond_to :json

      def create
        @claim = Claim.new(claim_params)

        if @claim.save
          @claim.submit!
          render json: @claim, status: :created
        else
          render json: { errors: @claim.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def claim_params
        params.require(:claim).permit(
         :advocate_id,
         :court_id,
         :case_number,
         :case_type,
         :offence_class,
         :additional_information,
         :vat_required,
         defendants_attributes: [:id, :claim_id, :first_name, :middle_name, :last_name, :date_of_birth, :representation_order_date, :order_for_judicial_apportionment, :maat_reference, :_destroy],
         fees_attributes: [:id, :claim_id, :fee_id, :quantity, :rate, :amount, :_destroy],
         expenses_attributes: [:id, :claim_id, :expense_type_id, :quantity, :rate, :hours, :amount, :_destroy]
        )
      end
    end
  end
end