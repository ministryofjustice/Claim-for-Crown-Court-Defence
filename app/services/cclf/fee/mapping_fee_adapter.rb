module CCLF
  module Fee
    class MappingFeeAdapter
      KEYS = %i[bill_type bill_subtype].freeze

      attr_reader :object
      attr_reader :mappings

      delegate :bill_type, :bill_subtype, to: :@bill_types

      def self.zip(bill_types = [])
        Hash[KEYS.zip(bill_types)]
      end

      def initialize(object)
        @object = object
        @mappings = bill_mappings
        @bill_types = OpenStruct.new(mappings[bill_key])
      end

      def maps?
        bill_type.present?
      end

      def bill_scenario
        case_type_adapter.bill_scenario
      end

      private

      def bill_mappings
        raise 'Implement in sub-class'
      end

      def bill_key
        raise 'Implement in sub-class'
      end

      def case_type_adapter
        @adapter ||= ::CCLF::CaseTypeAdapter.new(object.claim.case_type)
      end

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
