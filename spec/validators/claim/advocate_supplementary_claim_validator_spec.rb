require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateSupplementaryClaimValidator, type: :validator do
  include_context "force-validation"

  let(:claim) { create(:advocate_supplementary_claim) }

  before(:all) do
    seed_fee_schemes
    seed_fee_types
  end

  after(:all) do
    clean_database
  end

  include_examples "common advocate litigator validations", :advocate, case_type: false
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

  # TODO: misc fee uplifts can be shared with advocate claim
  context 'defendant uplift fees aggregation validation' do
    let(:midth) { Fee::MiscFeeType.find_by(unique_code: 'MIDTH') }
    let(:midhu) { Fee::MiscFeeType.find_by(unique_code: 'MIDHU') }
    let(:midtw) { Fee::MiscFeeType.find_by(unique_code: 'MIDTW') }
    let(:midwu) { Fee::MiscFeeType.find_by(unique_code: 'MIDWU') }
    let(:misc_fee) { claim.misc_fees.find_by(fee_type_id: midtw.id) }

    before do
      claim.misc_fees.delete_all
      create(:misc_fee, fee_type: midtw, claim: claim, quantity: 1, rate: 25.1)
      claim.reload
      claim.form_step = :miscellaneous_fees
    end

    it 'test setup' do
      expect(claim.defendants.size).to eql 1
      expect(claim.misc_fees.size).to eql 1
      expect(claim.misc_fees.first.fee_type).to have_attributes(unique_code: 'MIDTW')
    end

    context 'with 1 defendant' do
      context 'when there are 0 uplifts' do
        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to match_array(%w[MIDTW])
        end

        it 'should not error' do
          should_not_error(claim, :base)
        end
      end

      context 'when there is 1 miscellanoues fee uplift' do
        before do
          create(:misc_fee, fee_type: midwu, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to match_array(%w[MIDWU MIDTW])
        end

        it 'should error' do
          should_error_with(claim, :base, 'defendant_uplifts_misc_fees_mismatch')
        end

        context 'when from api' do
          before do
            allow(claim).to receive(:from_api?).and_return true
          end

          it 'should not error' do
            should_not_error(claim, :base)
          end
        end
      end

      context 'with 2 defendants' do
        before do
          create(:defendant, claim: claim)
          create(:misc_fee, fee_type: midth, claim: claim, quantity: 1, amount: 21.01)
          claim.reload
        end

        context 'when there are multiple uplifts of 1 per fee type' do
          before do
            create(:misc_fee, fee_type: midhu, claim: claim, quantity: 1, amount: 21.01)
            create(:misc_fee, fee_type: midwu, claim: claim, quantity: 1, amount: 21.01)
          end

          it 'test setup' do
            expect(claim.defendants.size).to eql 2
            expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to match_array(%w[MIDTH MIDHU MIDTW MIDWU])
          end

          it 'should not error' do
            should_not_error(claim, :base)
          end
        end

        context 'when there are multiple uplifts of 2 (or more) per fee type' do
          before do
            create(:misc_fee, fee_type: midhu, claim: claim, quantity: 2, amount: 21.01)
            create(:misc_fee, fee_type: midwu, claim: claim, quantity: 2, amount: 21.01)
          end

          it 'test setup' do
            expect(claim.defendants.size).to eql 2
            expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to match_array(%w[MIDTH MIDHU MIDTW MIDWU])
          end

          it 'should add one error only' do
            should_error_with(claim, :base, 'defendant_uplifts_misc_fees_mismatch')
            expect(claim.errors[:base].size).to eql 1
          end
        end
      end

      context 'defendant uplifts fee marked for destruction' do
        before do
          create(:misc_fee, fee_type: midwu, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to match_array(%w[MIDWU MIDTW])
          expect(claim).to be_invalid
        end

        it 'are ignored' do
          midwu_fee = claim.fees.joins(:fee_type).where(fee_types: { unique_code: 'MIDWU' }).first
          claim.update(
            :misc_fees_attributes => {
              '0' => {
                'id' => midwu_fee.id,
                '_destroy' => '1'
              }
            }
          )
          expect(claim).to be_valid
        end
      end

      context 'defendants marked for destruction' do
        before do
          create(:defendant, claim: claim)
          create(:misc_fee, fee_type: midwu, claim: claim, quantity: 1, amount: 21.01)
          claim.reload
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 2
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to match_array(%w[MIDWU MIDTW])
          expect(claim).to be_valid
        end

        it 'are ignored' do
          claim.update(
            :defendants_attributes => {
              '0' => {
                'id' => claim.defendants.first.id,
                '_destroy' => '1'
              }
            }
          )
          expect(claim).to be_invalid
        end
      end
    end
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
