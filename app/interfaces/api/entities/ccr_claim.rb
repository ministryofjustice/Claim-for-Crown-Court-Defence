# current endpoint: GET /api/ccr/claims{uuid}
# target endpoint: GET api/claims{uuid}
#
# This API endpoint is intended to be replaced by the GET api/claims{uuid} endpoint
# however the following fields are CCR specific:
#
#   - feeStructureId
#   - scenario
#

module API
  module Entities
    class CCRClaim < BaseEntity

      expose :_cccd do
        expose :id
        expose :uuid
      end

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
        AdvocateCategoryAdapter.code_for(object.advocate_category) if object.advocate_category.present?
      end

      def fee_quantity_for(fee_type_unique_code)
        object.fees.find_by(fee_type_id: ::Fee::BaseFeeType.find_by_id_or_unique_code(fee_type_unique_code))&.quantity.to_i
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

      def daily_attendance_fee_types
        ::Fee::BasicFeeType.where(unique_code: %w[BADAF BADAH BADAJ])
      end

      def daily_attendance_uplifts
        @attendance_uplifts ||= object.fees.where(fee_type_id: daily_attendance_fee_types).sum(:quantity).to_i
      end

      def daily_attendance_uplifts?
        daily_attendance_uplifts > 0
      end

      # The first 2 daily attendances are included in the Basic Fee (BAF)
      DAILY_ATTENDANCES_IN_BASIC = 2.freeze
      def daily_attendances
        if daily_attendance_uplifts?
          daily_attendance_uplifts + DAILY_ATTENDANCES_IN_BASIC
        else
          [object.actual_trial_length, DAILY_ATTENDANCES_IN_BASIC].compact.min
        end
      end

      # The "Advocate Fee" is the CCR equivalent of all most but not
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
          bill_type: 'AGFS_FEE',
          bill_subtype: 'AGFS_FEE',
          quantity: 1.0,
          rate: 0.0,
          ppe: pages_of_prosecution_evidence,
          number_of_cases: number_of_cases,
          number_of_witnesses: number_of_witnesses,
          daily_attendances: daily_attendances,
          conferences_and_views_refno: 0, # CCR required only - CAV record/instance number/occurence - could be removed if CCR defaults to 0
          conferences_and_views_at: nil, # CCR required only - CAV record/instance date, not available in CCCD. could be removed if CCR can default
          calculatedFee: {
            basicCaseFee: 0.0,
            date: object.last_submitted_at.strftime('%Y-%m-%d %H:%M:%S'),
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

      def bills
        [
          advocate_fee
        ]
      end
    end
  end
end
