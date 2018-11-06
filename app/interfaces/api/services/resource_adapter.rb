module API
  module Services
    class ResourceAdapter
      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def call
        if resource.is_a?(::Fee::FixedFee) && uncalculatable?
          resource.assign_attributes(quantity: 1, rate: resource.amount, amount: nil)
        end
        resource
      end

      private

      def uncalculatable?
        [resource.quantity.blank?, resource.rate.blank?, resource.amount.present?].all?
      end
    end
  end
end
