require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateClaimValidator, type: :validator do
  include_context "force-validation"

  let(:claim) { create(:advocate_claim) }

  before { seed_fee_schemes }

  include_examples "common advocate litigator validations", :advocate
  include_examples 'advocate claim case concluded at'
  include_examples 'advocate claim external user role'
  include_examples 'advocate claim creator role'
  include_examples 'advocate claim supplier number'

  context 'advocate_category' do
    default_valid_categories = ['QC', 'Led junior', 'Leading junior', 'Junior alone']
    fee_reform_valid_categories = ['QC', 'Leading junior', 'Junior']
    fee_reform_invalid_categories = default_valid_categories - fee_reform_valid_categories
    all_valid_categories = (default_valid_categories + fee_reform_valid_categories).uniq

    # API behaviour is different because fixed fees
    # do not require an offence so cannot rely on
    # either offence or rep order date to determine valid
    # advocate categories
    context 'when claim from API' do
      context 'with scheme 9 offence' do
        let(:claim) { create(:api_advocate_claim, :with_scheme_nine_offence) }

        default_valid_categories.each do |category|
          it "should not error if '#{category}' specified" do
            claim.advocate_category = category
            should_not_error(claim, :advocate_category)
          end
        end
      end

      context 'with scheme 10 offence' do
        let(:claim) { create(:api_advocate_claim, :with_scheme_ten_offence) }

        fee_reform_valid_categories.each do |category|
          it "should not error if '#{category}' specified" do
            claim.advocate_category = category
            should_not_error(claim, :advocate_category)
          end
        end
      end

      context 'with no offence (fixed fee case type)' do
        let(:claim) { create(:api_advocate_claim, :with_no_offence) }

        all_valid_categories.each do |category|
          it "should not error if '#{category}' specified" do
            claim.advocate_category = category
            should_not_error(claim, :advocate_category)
          end
        end
      end
    end

    context 'when on the basic fees step' do
      include_examples 'advocate category validations', factory: :advocate_claim, form_step: 'basic_fees'
    end

    context 'when on the fixed fees step' do
      include_examples 'advocate category validations', factory: :advocate_claim, form_step: 'fixed_fees'
    end
  end

  context 'offence' do
    before do
      claim.form_step = :offence_details
      claim.offence = nil
    end

    it 'should error if not present for non-fixed fee case types' do
      allow(claim.case_type).to receive(:is_fixed_fee?).and_return(false)
      should_error_with(claim, :offence, "blank")
    end

    it 'should NOT error if not present for fixed fee case types' do
      allow(claim.case_type).to receive(:is_fixed_fee?).and_return(true)
      should_not_error(claim, :offence)
    end

    context 'when the claim is associated with the new fee reform scheme' do
      let(:claim) { create(:claim, :agfs_scheme_10) }

      context 'and case type is for non-fixed fees' do
        before do
          allow(claim.case_type).to receive(:is_fixed_fee?).and_return(false)
        end

        it 'should error if not present' do
          should_error_with(claim, :offence, 'new_blank')
        end
      end

      context 'and case type is for fixed fees' do
        before do
          allow(claim.case_type).to receive(:is_fixed_fee?).and_return(true)
        end

        it 'should NOT error if not present' do
          should_not_error(claim, :offence)
        end
      end
    end
  end

  context 'defendant uplift fees aggregation validation' do
    let(:miaph) { create(:misc_fee_type, :miaph) }
    let(:miahu) { create(:misc_fee_type, :miahu) }
    let(:midtw) { create(:misc_fee_type, :midtw) }
    let(:midwu) { create(:misc_fee_type, :midwu) }
    let(:misc_fee) { claim.misc_fees.find_by(fee_type_id: miaph.id) }

    before do
      claim.misc_fees.delete_all
      create(:misc_fee, fee_type: miaph, claim: claim, quantity: 1, rate: 25.1)
      claim.reload
      claim.form_step = :miscellaneous_fees
    end

    it 'test setup' do
      expect(claim.defendants.size).to eql 1
      expect(claim.misc_fees.size).to eql 1
      expect(claim.misc_fees.first.fee_type).to have_attributes(unique_code: 'MIAPH')
    end

    context 'with 1 defendant' do
      context 'when there are 0 uplifts' do
        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to eql(%w[MIAPH])
        end

        it 'should not error' do
          should_not_error(claim, :base)
        end
      end

      context 'when there is 1 miscellanoues fee uplift' do
        before do
          create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH])
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

      context 'when there is 1 basic fee uplift' do
        before do
          create(:basic_fee, :ndr_fee, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.basic_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[BANDR])
        end

        it 'should not error' do
          should_not_error(claim, :base)
        end

        context 'and form step is basic fees' do
          before do
            claim.form_step = :basic_fees
          end

          it 'should error' do
            should_error_with(claim, :base, 'defendant_uplifts_basic_fees_mismatch')
          end
        end
      end

      context 'when there is 1 fixed fee uplift' do
        let(:claim) { create(:advocate_claim, :with_fixed_fee_case) }

        before do
          fxsaf = create(:fixed_fee_type, :fxsaf, id: 10000)
          fxndr = create(:fixed_fee_type, :fxndr, id: 10001)
          create(:fixed_fee, fee_type: fxsaf, claim: claim, quantity: 1, rate: 21.01)
          create(:fixed_fee, fee_type: fxndr, claim: claim, quantity: 1, rate: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.fixed_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[FXNDR FXSAF])
        end

        it 'should not error' do
          should_not_error(claim, :base)
        end

        context 'and form step is fixed fees' do
          before do
            claim.form_step = :fixed_fees
          end

          it 'should error on the uplift fee' do
            position = claim.fixed_fees.find_index(&:defendant_uplift?) + 1
            should_error_with(claim, "fixed_fee_#{position}_quantity", 'defendant_uplifts_fixed_fees_mismatch')
          end
        end
      end

      context 'with 2 defendants' do
        before do
          create(:defendant, claim: claim)
          create(:misc_fee, fee_type: midtw, claim: claim, quantity: 1, amount: 21.01)
          claim.reload
        end

        context 'when there are multiple uplifts of 1 per fee type' do
          before do
            create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
            create(:misc_fee, fee_type: midwu, claim: claim, quantity: 1, amount: 21.01)
          end

          it 'test setup' do
            expect(claim.defendants.size).to eql 2
            expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH MIDTW MIDWU])
          end

          it 'should not error' do
            should_not_error(claim, :base)
          end
        end

        context 'when there are multiple uplifts of 2 (or more) per fee type' do
          before do
            create(:misc_fee, fee_type: miahu, claim: claim, quantity: 2, amount: 21.01)
            create(:misc_fee, fee_type: midwu, claim: claim, quantity: 2, amount: 21.01)
          end

          it 'test setup' do
            expect(claim.defendants.size).to eql 2
            expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH MIDTW MIDWU])
          end

          it 'should add one error only' do
            should_error_with(claim, :base, 'defendant_uplifts_misc_fees_mismatch')
            expect(claim.errors[:base].size).to eql 1
          end
        end
      end

      context 'defendant uplifts fee marked for destruction' do
        before do
          create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH])
          expect(claim).to be_invalid
        end

        it 'are ignored' do
          miahu_fee = claim.fees.joins(:fee_type).where(fee_types: { unique_code: 'MIAHU' }).first
          claim.update(
            :misc_fees_attributes => {
              '0' => {
                'id' => miahu_fee.id,
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
          create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
          claim.reload
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 2
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH])
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
      case_type
      court
      case_number
      case_transferred_from_another_court
      transfer_court
      transfer_case_number
      estimated_trial_length
      actual_trial_length
      retrial_estimated_length
      retrial_actual_length
      trial_cracked_at_third
      trial_fixed_notice_at
      trial_fixed_at
      trial_cracked_at
      trial_dates
      retrial_started_at
      retrial_concluded_at
      case_concluded_at
      supplier_number
    ],
    defendants: [],
    offence_details: %i[offence],
    basic_fees: %i[total advocate_category defendant_uplifts_basic_fees],
    fixed_fees: %i[total advocate_category defendant_uplifts_fixed_fees],
    miscellaneous_fees: %i[defendant_uplifts_misc_fees],
    travel_expenses: %i[travel_expense_additional_information],
    supporting_evidence: []
  }
end
