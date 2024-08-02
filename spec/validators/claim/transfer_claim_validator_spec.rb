require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::TransferClaimValidator, type: :validator do
  include_context 'force-validation'

  let(:claim) { build(:transfer_claim, defendants: [build(:defendant)]) }
  let(:transfer_detail) { build(:transfer_detail, claim:) }

  before do
    claim.form_step = :case_details
    claim.force_validation = true
  end

  include_examples 'common partial validations', {
    transfer_fee_details: %i[
      litigator_type
      elected_case
      transfer_stage_id
      transfer_date
      case_conclusion_id
    ],
    case_details: %i[
      court_id
      case_number
      london_rates_apply
      case_transferred_from_another_court
      transfer_court_id
      transfer_case_number
      case_concluded_at
      supplier_number
      amount_assessed
      evidence_checklist_ids
      main_hearing_date
    ],
    defendants: [],
    offence_details: %i[offence],
    transfer_fees: %i[transfer_fee total],
    travel_expenses: %i[travel_expense_additional_information],
    supporting_evidence: []
  }

  context 'litigator type' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    it 'errors if not new or original' do
      expect_invalid_attribute_with_message(claim, :litigator_type, nil, 'Choose the litigator type')
    end

    it 'is valid if new' do
      expect_valid_attribute(claim, :litigator_type, 'new')
    end

    it 'is valid if original' do
      expect_valid_attribute(claim, :litigator_type, 'original')
    end
  end

  context 'elected_case' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    it 'errors if nil' do
      expect_invalid_attribute_with_message(claim, :elected_case, nil, 'Choose the elected case status')
    end

    it 'is valid if true' do
      expect_valid_attribute(claim, :elected_case, true)
    end

    it 'is valid if false' do
      expect_valid_attribute(claim, :elected_case, false)
    end
  end

  context 'transfer_stage_id' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    it 'errors if invalid id' do
      expect_invalid_attribute_with_message(claim, :transfer_stage_id, 33, 'Check the stage at which the case was transfered')
    end

    it 'is valid if a valid value' do
      expect_valid_attribute(claim, :transfer_stage_id, 40)
    end
  end

  context 'transfer_date' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    it 'errors if blank' do
      expect_invalid_attribute_with_message(claim, :transfer_date, nil, 'Enter the transfer date')
    end

    it 'errors if in future' do
      expect_invalid_attribute_with_message(claim, :transfer_date, 2.days.from_now, 'Transfer date cannot be in the future')
    end

    it 'errors if too far in the past' do
      expect_invalid_attribute_with_message(claim, :transfer_date, 11.years.ago, 'Transfer date cannot be too far in the past')
    end

    it 'is valid if in the recent past' do
      expect_valid_attribute(claim, :transfer_date, 2.months.ago)
    end
  end

  context 'trial dates validation' do
    context 'case type: trial' do
      let(:claim) { build(:transfer_claim, :with_transfer_detail, defendants: [build(:defendant)]) }

      it 'factory builds claim without trial dates' do
        expect(claim.first_day_of_trial).to be_nil
      end

      it 'does not require trial dates' do
        expect(claim).to be_valid
      end
    end

    context 'case type: retrial' do
      let(:claim) { build(:transfer_claim, :with_transfer_detail, defendants: [build(:defendant)]) }

      it 'factory builds claim without trial dates' do
        expect(claim.retrial_started_at).to be_nil
      end

      it 'does not require retrial dates' do
        expect(claim).to be_valid
      end
    end
  end

  context 'case type validation' do
    let(:claim) { build(:transfer_claim, :with_transfer_detail, defendants: [build(:defendant)]) }

    it 'factory builds claim without case type' do
      expect(claim.case_type).to be_nil
    end

    it 'does not require case type' do
      expect(claim).to be_valid
    end
  end

  context 'case_conclusion' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    let(:claim) { build(:transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 30, case_conclusion_id: 10, defendants: [build(:defendant)]) }

    it 'is valid if a valid case conclusion id' do
      expect_valid_attribute claim, :case_conclusion_id, 20
    end

    it 'errors if not a valid case conclusion id' do
      expect_invalid_attribute_with_message(claim, :case_conclusion_id, 44, 'Check the case conclusion')
    end

    context 'presence and absence' do
      let(:claim) { build(:transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 50, case_conclusion_id: 10, defendants: [build(:defendant)]) }

      it 'errors if absent but required' do
        claim.transfer_stage_id = 30
        expect_invalid_attribute_with_message(claim, :case_conclusion_id, nil, 'Enter a case conclusion')
      end

      it 'errors if present but not required' do
        claim.transfer_stage_id = 40
        expect_invalid_attribute_with_message(claim, :case_conclusion_id, 10, 'Do not enter a case conclusion')
      end
    end
  end
end
