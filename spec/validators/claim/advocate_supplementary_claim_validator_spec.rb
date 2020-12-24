require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateSupplementaryClaimValidator, type: :validator do
  include_context 'force-validation'
  include_context 'seed-fee-schemes'

  let(:claim) { create(:advocate_supplementary_claim) }

  include_examples 'common advocate litigator validations', :advocate, case_type: false
  include_examples 'advocate claim case concluded at'
  include_examples 'advocate claim external user role'
  include_examples 'advocate claim creator role'
  include_examples 'advocate claim supplier number'

  context 'advocate_category' do
    context 'when on the misc fees step' do
      before do
        claim.form_step = 'miscellaneous_fees'
      end

      include_examples 'advocate category validations', factory: :advocate_supplementary_claim, form_step: 'miscellaneous_fees'
    end
  end

  context 'case_type' do
    before do
      claim.case_type = nil
    end

    it 'should NOT error if not present' do
      should_not_error(claim, :case_type)
    end
  end

  context 'offence' do
    before do
      claim.offence = nil
    end

    it 'should NOT error if not present' do
      should_not_error(claim, :offence)
    end
  end

  context 'defendant uplift fees aggregation validation' do
    include_examples 'common defendant uplift fees aggregation validation'
  end

  include_examples 'common partial validations', {
    case_details: %i[
      court
      case_number
      case_transferred_from_another_court
      transfer_court
      transfer_case_number
      case_concluded_at
      supplier_number
    ],
    defendants: [],
    miscellaneous_fees: %i[advocate_category defendant_uplifts_misc_fees total],
    travel_expenses: %i[travel_expense_additional_information],
    supporting_evidence: []
  }
end
