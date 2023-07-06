module ExternalUsers
  module Fees
    class AddUnclaimedsController < ExternalUsers::ApplicationController
      skip_load_and_authorize_resource
      before_action :set_claim, only: :create
      before_action :set_fees, only: :create

      def create
        return head :bad_request if @fees.empty?

        Claims::UpdateClaim.call(@claim, params: { misc_fees_attributes: @fees.map { |f| fee_attributes_for(f) } })

        head :created
      end

      private

      def set_claim
        @claim = Claim::BaseClaim.active.find(add_unclaimed_params[:claim_id])
      end

      def set_fees
        # @fees = (Fee::BaseFeeType.where(id: add_unclaimed_params[:fees]) & @claim.eligible_misc_fee_types) - claimed_fees
        @fees = (add_unclaimed_params[:fees].map(&:to_i) & @claim.eligible_misc_fee_types.map(&:id)) - claimed_fees
      end

      def claimed_fees
        @claim.fees.map(&:fee_type).pluck(:id)
      end

      def add_unclaimed_params
        params.permit(
          :claim_id,
          fees: []
        )
      end

      def fee_attributes_for(fee)
        calculator = Claims::FeeCalculator::UnitPrice.new(@claim, fee_type_id: fee, fees: {})
        {
          fee_type_id: fee,
          quantity: 1,
          rate: calculator.call&.data&.amount
        }
      end
    end
  end
end
