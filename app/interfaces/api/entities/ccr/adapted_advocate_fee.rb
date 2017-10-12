module API
  module Entities
    module CCR
      class AdaptedAdvocateFee < API::Entities::CCR::AdaptedBaseFee
        # irrelevant exposures for this consolidated "fee-of-fees"
        # but required by CCR (quantity) or to overide superclass
        expose :quantity
        expose :rate
        expose :amount

        # derived/transformed data exposures
        expose :ppe
        expose :number_of_witnesses
        expose :number_of_cases
        expose :case_numbers
        expose :daily_attendances

        # NOTE: for possible use in comparisons between CCCD and CCR calculation comparision
        # expose :calculated_fee, as: :calculatedFee

        private

        def quantity
          1.0
        end

        def rate
          0.0
        end

        def amount
          0.0
        end

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

        def case_numbers
          fee_for('BANOC')&.case_numbers
        end

        def daily_attendances
          ::CCR::DailyAttendanceAdapter.attendances_for(object)
        end

        def calculated_fee
          {
            basicCaseFee: 0.0,
            date: object.last_submitted_at&.strftime('%Y-%m-%d %H:%M:%S'),
            defendantUplift: 0.0,
            exVat: 0.0,
            incVat: 0.0,
            ppeUplift: 0.0,
            trialLengthUplift: 0.0,
            vat: 0.0,
            vatIncluded: true,
            vatRate: 20.0
          }
        end
      end
    end
  end
end
