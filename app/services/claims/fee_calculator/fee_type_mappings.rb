# Singleton object to map fee types in CCCD to fee types
# in laa fee calculator.
#
module Claims
  module FeeCalculator
    class FeeTypeMappings
      include Singleton

      ADAPTERS = [
        CCR::Fee::BasicFeeAdapter,
        CCR::Fee::FixedFeeAdapter,
        CCR::Fee::MiscFeeAdapter
      ].freeze

      def self.reset
        instance.instance_variable_set(:@all, nil)
        instance.instance_variable_set(:@primary_fee_types, nil)
        instance.instance_variable_set(:@primary_fee_type_codes, nil)
      end

      def all
        @all ||= ADAPTERS.each_with_object({}) do |adapter, mappings|
          mappings.merge!(adapter.new(exclusions: false).mappings)
        end
      end

      def primary_fee_types
        @primary_fee_types ||= all.slice(*primary_fee_type_codes)
      end

      private

      def primary_fee_type_codes
        @primary_fee_type_codes ||= CaseType.pluck(:fee_type_code).compact.map(&:to_sym).append(:BABAF)
      end
    end
  end
end
