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
      AGFS_FEE_SCHEME_9_CCR_FEE_STRUCTURE_ID = 10

      expose :_cccd do
        expose :id
        expose :uuid
      end

      expose :supplier do
        expose :supplier_number, as: :accountNumber
      end

      expose :case_number, as: :caseNumber
      expose :court do
        expose :court_code, as: :code
      end

      expose :first_defendant_maat_number, as: :representationOrderNumber
      expose :first_defendant_rep_order_date, as: :representationOrderDate, format_with: :utc

      expose :wrapped_bill, as: :bills

      expose :empty, as: :associatedCases

      expose :fee_structure_id, as: :feeStructureId

      expose :estimated_trial_length_or_one, as: :estimatedTrialLength
      expose :actual_trial_length_or_one, as: :actualTrialLength
      expose :first_day_of_trial, as: :trialStartDate

      expose :number_of_witnesses, as: :noOfWitnesses

      expose :personType do
        expose :advocate_category, as: :personType
      end

      expose :case_number, as: :origCaseNumber

      expose :offenceCode do
        expose :offence_code_id, as: :id
      end

      expose :offenceClass do
        expose :offence_class_code, as: :code
      end

      expose :scenario do
        expose :fee_structure_id, as: :feeStructureId
        expose :scenario
      end

      private

      # fee type ids
      CASES_UPLIFT = 9
      WITNESSES = 10
      PPE = 11

      def empty
        []
      end

      def zero
        0
      end

      def fee_quantity_for(fee_type_id)
        object.fees.find_by(fee_type_id: fee_type_id)&.quantity&.to_i || 0
      end

      def court_code
        object.court&.code
      end

      def first_defendant_maat_number
        object.defendants.first.representation_orders.first.maat_reference
      end

      def first_defendant_rep_order_date
        object.defendants.first.representation_orders.first.representation_order_date
      end

      def fee_structure_id
        AGFS_FEE_SCHEME_9_CCR_FEE_STRUCTURE_ID
      end

      def scenario
        object.case_type.bill_scenario
      end

      def estimated_trial_length_or_one
        return 1 if object.estimated_trial_length.zero? || object.estimated_trial_length.nil?
        object.estimated_trial_length
      end

      def actual_trial_length_or_one
        return 1 if object.actual_trial_length.zero? || object.actual_trial_length.nil?
        object.actual_trial_length
      end

      def advocate_category
        AdvocateCategoryAdapter.code_for(object.advocate_category) if object.advocate_category.present?
      end

      def offence_class_code
        object.offence&.offence_class&.class_letter
      end

      def offence_code_id
        # Using CCR Legacy Offence codes 501-511 for now (which map 1-to-1 onto offence classes)
        ('A'..'K').zip(501..511).to_h[offence_class_code]
      end

      def number_of_witnesses
        fee_quantity_for(WITNESSES)
      end

      # CCR bill type maps to the class/type of a BaseFeeType
      # e.g. AGFS_FEE bill_type is the BasicFeeType
      def bill_type
        'AGFS_FEE'
      end

      # CCR bill sub types map to individual/unique fee types
      # e.g. AGFS_FEE subtype is the BasicFeeType's Basic fee (i.e. BAF)
      def bill_subtype
        'AGFS_FEE'
      end

      # every claim is based on one case (i.e. see case number) but may involve others
      def number_of_cases
        fee_quantity_for(CASES_UPLIFT) + 1
      end

      def pages_of_prosecution_evidence
        fee_quantity_for(PPE)
      end

      # The "Advocate Fee" is the CCR equivalent of all the
      # BasicFeeType fees in CCCD.
      # The Advocate Fee is of type AGFS_FEE and subtype AGFS_FEE
      def advocate_fee
        {
          billType: {
            billType: bill_type
          },
          billSubType: {
            billSubType: bill_subtype
          },
          userCreatedRole: 'CCRGradeB1',
          ppe: pages_of_prosecution_evidence,
          quantity: 1.0,
          rate: 0.0,
          dateNotice1stFixedWarn: nil,
          firstFixedWarnedDate: nil,
          dateOfCrack: nil,
          thirdCracked: nil,
          forceThirdCracked: nil,
          dateIncurred: object.last_submitted_at.strftime('%Y-%m-%d %H:%M:%S'),
          noOfCases: number_of_cases,
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
          },
          refno: 0,
          occurDate: nil,
          firstFixedWarnedDateOrig: nil,
          caseUpliftAmount: 0.0,
          defendantUpliftAmount: 0.0
        }
      end

      def wrapped_bill
        [
          advocate_fee
        ]
      end
    end
  end
end
