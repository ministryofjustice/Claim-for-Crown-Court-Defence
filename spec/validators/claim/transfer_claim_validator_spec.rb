require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::TransferClaimValidator, type: :validator do
  include_context 'force-validation'

  let(:claim) { build :transfer_claim }
  let(:transfer_detail) { build :transfer_detail, claim: claim }

  include_examples 'common partial validations', {
    transfer_fee_details: %i[
      litigator_type
      elected_case
      transfer_stage_id
      transfer_date
      case_conclusion_id
      transfer_detail_combo
    ],
    case_details: %i[
      court
      case_number
      case_transferred_from_another_court
      transfer_court
      transfer_case_number
      case_concluded_at
      supplier_number
      amount_assessed
      evidence_checklist_ids
    ],
    defendants: [],
    offence_details: %i[offence],
    transfer_fees: %i[transfer_fee total],
    travel_expenses: %i[travel_expense_additional_information],
    supporting_evidence: []
  }

  before do
    claim.form_step = :case_details
    claim.force_validation = true
  end

  context 'litigator type' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    it 'errors if not new or original' do
      expect_invalid_attribute_with_message(claim, :litigator_type, 'xxx', 'invalid')
    end

    it 'is valid if new or original' do
      expect_valid_attribute(claim, :litigator_type, 'new')
      expect_valid_attribute(claim, :litigator_type, 'original')
    end
  end

  context 'elected_case' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    it 'errors if nil' do
      expect_invalid_attribute_with_message(claim, :elected_case, nil, 'invalid')
    end

    it 'is valid if true or false' do
      expect_valid_attribute(claim, :elected_case, true)
      expect_valid_attribute(claim, :elected_case, false)
    end
  end

  context 'transfer_stage_id' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    it 'errors if invalid id' do
      expect_invalid_attribute_with_message(claim, :transfer_stage_id, 33, 'invalid')
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
      expect_invalid_attribute_with_message(claim, :transfer_date, nil, 'blank')
    end

    it 'errors if in future' do
      expect_invalid_attribute_with_message(claim, :transfer_date, 2.days.from_now, 'check_not_in_future')
    end

    it 'errors if too far in the past' do
      expect_invalid_attribute_with_message(claim, :transfer_date, 11.years.ago, 'check_not_too_far_in_past')
    end

    it 'is valid if in the recent past' do
      expect_valid_attribute(claim, :transfer_date, 2.months.ago)
    end
  end

  context 'trial dates validation' do
    context 'case type: trial' do
      let(:claim) { build(:transfer_claim, :with_transfer_detail) }

      it 'factory builds claim without trial dates' do
        expect(claim.first_day_of_trial).to be_nil
      end

      it 'should not require trial dates' do
        expect(claim).to be_valid
      end
    end
    context 'case type: retrial' do
      let(:claim) { build(:transfer_claim, :with_transfer_detail) }

      it 'factory builds claim without trial dates' do
        expect(claim.retrial_started_at).to be_nil
      end

      it 'should not require retrial dates' do
        expect(claim).to be_valid
      end
    end
  end

  context 'case type validation' do
    let(:claim) { build(:transfer_claim, :with_transfer_detail) }

    it 'factory builds claim without case type' do
      expect(claim.case_type).to be_nil
    end

    it 'should not require case type' do
      expect(claim).to be_valid
    end
  end

  context 'case_conclusion' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    let(:claim) { build(:transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 30, case_conclusion_id: 10) }

    it 'is valid if a valid case conclusion id' do
      expect_valid_attribute claim, :case_conclusion_id, 20
    end

    it 'errors if not a valid case conclusion id' do
      expect_invalid_attribute_with_message(claim, :case_conclusion_id, 44, 'invalid')
    end

    context 'presence and absence' do
      let(:claim) { build(:transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 50, case_conclusion_id: 10) }

      it 'should error if absent but required' do
        claim.transfer_stage_id = 30
        expect_invalid_attribute_with_message(claim, :case_conclusion_id, nil, 'blank')
      end
      it 'should error if present but not required' do
        claim.transfer_stage_id = 40
        expect_invalid_attribute_with_message(claim, :case_conclusion_id, 10, 'present')
      end
    end
  end

  context 'transfer_details combination' do
    before do
      claim.form_step = :transfer_fee_details
      claim.force_validation = true
    end

    let(:claim) { build(:transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 50, case_conclusion_id: 10) }

    it 'adds a transfer detail combination error for invalid combinations' do
      expect(claim).not_to be_valid
      expect(claim.errors[:transfer_detail]).to include('invalid_combo')
    end

    it 'adds a specifc error on case conclusion id for invalid combinations to help resolve them' do
      expect(claim).not_to be_valid
      expect(claim.errors[:case_conclusion_id]).to include('invalid_combo')
    end

    it 'does not error if details are a valid combo' do
      claim.case_conclusion_id = 40
      claim.valid?
      expect(claim.errors[:transfer_detail]).not_to include('invalid_combo')
    end
  end
end
