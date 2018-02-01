module CCLF
  module Fee
    class SimpleFeeAdapter
      attr_reader :object

      def initialize(object)
        @object = object
      end

      def bill_type
        raise 'Implement in sub-class'
      end

      def bill_subtype
        raise 'Implement in sub-class'
      end

      def bill_scenario
        case_type_adapter.bill_scenario
      end

      private

      def case_type_adapter
        @adapter ||= ::CCLF::CaseTypeAdapter.new(object.claim.case_type)
      end

      # delegate missing methods to object if it can respond
      def method_missing(method, *args, &block)
        if object.respond_to?(method)
          object.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        object.respond_to?(method) || super
      end
    end
  end
end
