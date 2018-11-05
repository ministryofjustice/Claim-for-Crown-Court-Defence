module API
  module Services
    class ResourceAdapter
      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      # TODO: `uncalculatable?` logic should apply across all fees
      # but needs more robust testing for confidence
      def call
        if resource.is_a?(::Fee::FixedFee) && uncalculatable?
          resource.assign_attributes(quantity: 1, rate: resource.amount, amount: nil)
        end
        resource
      end

      private

      def uncalculatable?
        [
          resource.calculated?,
          resource.quantity.blank?,
          resource.rate.blank?,
          resource.amount.present?
        ].all?
      end
    end
  end
end
