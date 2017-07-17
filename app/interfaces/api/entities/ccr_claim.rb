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

      expose :zero, as: :noOfWitnesses

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

      def empty
        []
      end

      def zero
        0
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
        'AS000004' # Hardcoded for "trial" case type
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

      def wrapped_bill
        [{
          billType: {
            billType: 'AGFS_FEE'
          },
          billSubType: {
            billSubType: 'AGFS_FEE'
          },
          userCreatedRole: 'CCRGradeB1',
          ppe: object.fees.where(fee_type_id: 11)&.first&.quantity&.to_i,
          quantity: 1.0,
          rate: 0.0,
          dateNotice1stFixedWarn: nil,
          firstFixedWarnedDate: nil,
          dateOfCrack: nil,
          thirdCracked: nil,
          forceThirdCracked: nil,
          dateIncurred: object.last_submitted_at.strftime('%Y-%m-%d %H:%M:%S'),
          noOfCases: 1,
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
        }]
      end
    end
  end
end
