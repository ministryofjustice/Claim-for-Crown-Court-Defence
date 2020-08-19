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
      private

      # TODO: At time of writing the AGFS case uplift fee types are
      # not requiring case numbers due to impact on the API
      # but this SHOULD change for CCR compatability.
      #

      delegate :case_uplift?, :case_numbers, :quantity, :fee_type, :claim, to: :@record

      def validate_case_numbers
        return if fee_type&.unique_code.nil?

        if case_uplift?
          validate_case_numbers_presence
          validate_case_numbers_quantity_mismatch if claim.agfs?
          validate_each_case_number
        else
          validate_absence(:case_numbers, 'present')
        end
      end

      # TODO: on or after 1st April 2018 the API should also enforce presence
      def validate_case_numbers_presence
        validate_presence(:case_numbers, 'blank') if claim.lgfs?
        validate_presence(:case_numbers, 'blank') if [claim.agfs?, quantity.to_i.positive?, !claim&.api_draft?].all?
      end

      def validate_case_numbers_quantity_mismatch
        return if case_numbers.blank?
        add_error(:case_numbers, 'noc_qty_mismatch') if case_numbers.split(',').size != quantity
      end

      def validate_each_case_number
        return if case_numbers.blank?

        case_numbers.split(',').each do |case_number|
          case_number = case_number.strip
          validate_case_number(case_number)
        end
      end

      def validate_case_number(case_number)
        if Settings.urn_enabled?
          validate_case_number_or_urn_pattern(case_number)
        else
          validate_case_number_pattern(case_number)
        end
        add_error(:case_numbers, 'eqls_claim_case_number') if case_number.casecmp?(claim.case_number)
      end

      def validate_case_number_or_urn_pattern(case_number)
        add_error(:case_numbers, 'invalid') unless case_number.match?(BaseValidator::CASE_URN_PATTERN)
        validate_case_number_pattern(case_number) if case_number.match?(BaseValidator::CASE_NUMBER_OR_URN_PATTERN)
      end

      def validate_case_number_pattern(case_number)
        add_error(:case_numbers, 'invalid') unless case_number.match?(BaseValidator::CASE_NUMBER_PATTERN)
      end
    end
  end
end
