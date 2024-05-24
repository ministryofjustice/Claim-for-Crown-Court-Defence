module CCR
  module Fee
    module BasicFeeAdaptable
      extend ActiveSupport::Concern

      included do
        def initialize(object = nil)
          super if object
        end

        def mappings
          @mappings ||= fee_types.each_with_object({}) do |fee_type_unique_code, mappings|
            mappings[fee_type_unique_code.to_sym] = { bill_type:, bill_subtype: }
          end
        end

        def claimed?
          filtered_fees.any? do |f|
            f.amount&.positive? || f.quantity&.positive? || f.rate&.positive?
          end
        rescue NameError
          raise ArgumentError, 'Instantiate with claim object to use this method'
        end

        def fee_types
          %w[BABAF BADAF BADAH BADAJ BADAT BANOC BANDR BANPW BAPPE]
        end

        def filtered_fees
          fees.select do |f|
            fee_types.include?(f.fee_type.unique_code)
          end
        end
      end
    end
  end
end
