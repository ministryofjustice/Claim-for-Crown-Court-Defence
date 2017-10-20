# Shared validators for fees requiring additional case numbers
# namely, BANOC and FXNOC (AGFS) and MIXUPL (LGFS).
#
# Any fee type that requires this validaiton should implement
# a case_uplift? method that returns true for the specific fee
# requiring the validation.
#
module Fee
  module Concerns
    module CaseNumbersValidator
      CASE_NUMBER_PATTERN = BaseValidator::CASE_NUMBER_PATTERN

      private

      # NOTE: LGFS fee of MIUPL/XUPL implements similar logic
      # but does not require a quantity and therefore
      # cannot implement the quantity mismatch validation.
      #
      # TODO: At time of writing the AGFS case uplift fee types are
      # not requiring case numbers due to impact on the API
      # but this SHOULD change for CCR compatability.
      #

      delegate :case_uplift?, :case_numbers, :quantity, :fee_type, to: :@record

      def validate_case_numbers
        return if fee_type&.unique_code.nil?

        if case_uplift?
          validate_presence(:case_numbers, 'blank') if fee_type.lgfs?
          validate_quantity_case_number_mismatch if fee_type.agfs?
          validate_each_case_number
        else
          validate_absence(:case_numbers, 'present')
        end
      end

      def validate_quantity_case_number_mismatch
        return if case_numbers.blank?
        add_error(:case_numbers, 'noc_qty_mismatch') if case_numbers.split(',').size != quantity
      end

      def validate_each_case_number
        return if case_numbers.blank?

        case_numbers.split(',').each do |case_number|
          unless case_number.strip.match?(CASE_NUMBER_PATTERN)
            add_error(:case_numbers, 'invalid')
            break
          end
        end
      end
    end
  end
end
