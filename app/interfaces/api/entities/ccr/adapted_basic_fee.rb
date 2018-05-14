module API
  module Entities
    module CCR
      class AdaptedBasicFee < AdaptedBaseFee
        with_options(format_with: :string) do
          expose :ppe
          expose :number_of_witnesses
          expose :number_of_cases
          expose :number_of_defendants
          expose :daily_attendances
        end

        expose :case_numbers

        private

        def fee_for(fee_type_unique_code)
          object.fees.find_by(fee_type_id: ::Fee::BaseFeeType.find_by_id_or_unique_code(fee_type_unique_code))
        end

        def fee_quantity_for(fee_type_unique_code)
          fee_for(fee_type_unique_code)&.quantity.to_i
        end

        def ppe
          fee_quantity_for('BAPPE')
        end

        def number_of_witnesses
          fee_quantity_for('BANPW')
        end

        # every claim is based on one case (i.e. see case number) but may involve others
        def number_of_cases
          fee_quantity_for('BANOC') + 1
        end

        def number_of_defendants
          fee_quantity_for('BANDR') + 1
        end

        def case_numbers
          fee_for('BANOC')&.case_numbers
        end

        def daily_attendances
          ::CCR::DailyAttendanceAdapter.attendances_for(object)
        end
      end
    end
  end
end
