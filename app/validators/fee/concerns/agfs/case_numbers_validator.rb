# Shared validators for AGFS fees requiring additional case numbers
# namely, BANOC and FXNOC.
#
# Any fee type that requires this validaiton should implement
# a case_uplift? method that returns true for the specific fee
# requiring the validation.
#
# NOTE: LGFS fee of MIXUPL implements similar logic and
# could make use of this if the differences can be ironed out.
# but a time of writing LGFS MIXUPL does not have a quantity.
#
module Fee
  module Concerns
    module Agfs
      module CaseNumbersValidator
        CASE_NUMBER_PATTERN = BaseValidator::CASE_NUMBER_PATTERN

        private

        def validate_case_numbers
          return if fee_code.nil?

          if case_uplift_fee?
            # TODO: not requiring presence yet until API/consumer/vendor comms considered
            validate_quantity_case_number_mismatch(:case_numbers, 'noc_qty_mismatch')
            validate_each_case_number(:case_numbers, 'invalid')
          else
            validate_absence(:case_numbers, 'present')
          end
        end

        def validate_quantity_case_number_mismatch(attribute, message)
          return if @record.__send__(attribute).blank?

          case_numbers = @record.__send__(attribute)
          add_error(attribute, message) if case_numbers.split(',').size != @record.quantity
        end

        def validate_each_case_number(attribute, message)
          return if @record.__send__(attribute).blank?

          @record.__send__(attribute).split(',').each do |case_number|
            unless case_number.strip.match(CASE_NUMBER_PATTERN)
              add_error(attribute, message)
              break
            end
          end
        end

        def case_uplift_fee?
          @record.fee_type.case_uplift?
        end
      end
    end
  end
end
