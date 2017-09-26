# This is a work in progress, aiming to provide all
# data possible to enable successful injection
# of a claim into CCR.
#
module API
  module Entities
    class CCRClaim < BaseEntity
      expose :uuid
      expose :supplier_number
      expose :case_number
      expose  :first_day_of_trial,
              :trial_fixed_notice_at,
              :trial_fixed_at,
              :trial_cracked_at,
              :last_submitted_at,
              format_with: :utc
      expose :trial_cracked_at_third

      expose :case_type, using: API::Entities::CCR::CaseType
      expose :court, using: API::Entities::CCR::Court
      expose :offence, using: API::Entities::CCR::Offence
      expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

      # CCR fields that can be derived from CCCD data
      expose :estimated_trial_length_or_one, as: :estimated_trial_length
      expose :actual_trial_length_or_one, as: :actual_trial_Length
      # ----------------------------------------------

      # CCR fields whose values can, and are, mapped to a CCCD field's values
      expose :adapted_advocate_category, as: :advocate_category
      # ----------------------------------------------

      # wrapper for the mapping of CCCD fees to CCR bills
      expose :bills

      private

      def defendants_with_main_first
        object.defendants.order(created_at: :asc)
      end

      def estimated_trial_length_or_one
        [object.estimated_trial_length, 1].compact.max
      end

      def actual_trial_length_or_one
        [object.actual_trial_length, 1].compact.max
      end

      def adapted_advocate_category
        ::CCR::AdvocateCategoryAdapter.code_for(object.advocate_category) if object.advocate_category.present?
      end

      def fee_for(fee_type_unique_code)
        object.fees.find_by(fee_type_id: ::Fee::BaseFeeType.find_by_id_or_unique_code(fee_type_unique_code))
      end

      def fee_quantity_for(fee_type_unique_code)
        fee_for(fee_type_unique_code)&.quantity.to_i
      end

      def pages_of_prosecution_evidence
        fee_quantity_for('BAPPE')
      end

      def number_of_witnesses
        fee_quantity_for('BANPW')
      end

      # every claim is based on one case (i.e. see case number) but may involve others
      def number_of_cases
        fee_quantity_for('BANOC') + 1
      end

      def additional_case_numbers
        fee_for('BANOC')&.case_numbers
      end

      def daily_attendances
        ::CCR::DailyAttendanceAdapter.attendances_for(object)
      end

      # The "Advocate Fee" is the CCR equivalent of most but not
      # all the BasicFeeType fees in CCCD. The Advocate Fee is of type
      # AGFS_FEE and subtype AGFS_FEE
      #
      # CCR bill type maps to the class/type of a BaseFeeType
      # e.g. AGFS_FEE bill_type is, almost, equivalent to the BasicFeeType
      #
      # CCR bill sub types map to individual/unique fee types
      # e.g. AGFS_FEE subtype represents the BasicFeeType's
      # BABAF,BACAV,BADAF,BADAH,BADAJ,BANOC,BANDR,BANPW,BAPPE
      # fee types, but not BASAF or BAPCM
      def advocate_fee
        {
          bill_type: advocate_fee_adapter.bill_type,
          bill_subtype: advocate_fee_adapter.bill_subtype,
          quantity: 1.0,
          rate: 0.0,
          ppe: pages_of_prosecution_evidence,
          number_of_cases: number_of_cases,
          case_numbers: additional_case_numbers,
          number_of_witnesses: number_of_witnesses,
          daily_attendances: daily_attendances,
          conferences_and_views_refno: 0, # CCR required only - CAV record/instance number/occurence - could be removed if CCR defaults to 0
          conferences_and_views_at: nil, # CCR required only - CAV record/instance date, not available in CCCD. could be removed if CCR can default
          calculatedFee: {
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
        }
      end

      def misc_fee_adapter
        @misc_fee_adapter ||= ::CCR::Fee::MiscFeeAdapter.new
      end

      def miscellaneous_fee(fee)
        misc_fee_adapter.call(fee)
        return unless misc_fee_adapter.bill_type && (fee.amount.positive? || fee.quantity.positive? || fee.rate.positive?)
        {
          bill_type: misc_fee_adapter.bill_type,
          bill_subtype: misc_fee_adapter.bill_subtype,
          # ref_no: '', # ???
          # occurence_date: '', # ??? attendance dates??
          quantity: fee.quantity.to_f,
          rate: fee.rate.to_f,
          amount: fee.amount.to_f,
          case_numbers: fee.case_numbers
        }
      end

      # CCR miscellaneous fees cover CCCD basic, fixed and miscellaneous fees
      #
      def miscellaneous_fees
        object.misc_fees + object.basic_fees + object.fixed_fees
      end

      def bills
        @bills ||= [].tap do |arr|
          arr << advocate_fee if advocate_fee_claimed?
          miscellaneous_fees.each do |misc_fee|
            arr << miscellaneous_fee(misc_fee)
          end
        end

        @bills.compact
      end

      def advocate_fee_types
        %w[BABAF BADAF BADAH BADAJ BANOC BANDR BANPW BAPPE]
      end

      def advocate_fees?
        object.basic_fees.any? do |f|
          advocate_fee_types.include?(f.fee_type.unique_code) &&
            (f.amount.positive? || f.quantity.positive? || f.rate.positive?)
        end
      end

      def advocate_fee_claimed?
        advocate_fee_adapter.bill_type && advocate_fees?
      end

      def advocate_fee_adapter
        @advocate_fee_adapter ||= ::CCR::Fee::AdvocateFeeAdapter.new.call(object)
      end

    end
  end
end
