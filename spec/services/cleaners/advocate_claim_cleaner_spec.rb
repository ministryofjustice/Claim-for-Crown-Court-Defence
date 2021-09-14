require 'rails_helper'

describe Cleaners::AdvocateClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  before do
    seed_case_types
    seed_fee_types
    seed_fee_schemes
  end

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    context 'with an "Appeal against sentence" case type including a fixed fee' do
      let(:claim) do
        create(:draft_claim, case_type: create(:case_type, :appeal_against_sentence), fixed_fees: fixed_fees)
      end
      let(:fixed_fees) { [build(:fixed_fee, :fxase_fee, :with_date_attended, rate: 9.99)] }

      context 'when the case type changes to "Appeal against conviction"' do
        before { claim.case_type = build(:case_type, :appeal_against_conviction) }

        it { expect { call_cleaner }.to change(claim.fixed_fees, :size).from(1).to 0 }
        it { expect { call_cleaner }.to change { claim.fixed_fees.count }.from(1).to 0 }
      end
    end

    context 'with a "Fixed fee" case type including a misc fee and a fixed fee' do
      let(:claim) { create(:draft_claim, :with_fixed_fee_case, fixed_fees: fixed_fees, misc_fees: misc_fees) }
      let(:misc_fees) { [build(:misc_fee, :miaph_fee, rate: 9.99)] }
      let(:fixed_fees) { [build(:fixed_fee, :fxase_fee, :with_date_attended, rate: 9.99)] }

      context 'when the case type is changed to one with graduated fees' do
        before do
          claim.case_type = build(:case_type, :trial)
          claim.basic_fees.build attributes_for(:basic_fee, :baf_fee, rate: 8.00)
        end

        it { expect { call_cleaner }.to change(claim.fixed_fees, :size).from(1).to 0 }
        it { expect { call_cleaner }.not_to change(claim.basic_fees, :size).from 1 }
        it { expect { call_cleaner }.not_to change(claim.misc_fees, :size).from 1 }
      end
    end

    context 'with a "Graduated fees" case type including basic fees' do
      subject(:claim) do
        create(:advocate_claim, :with_graduated_fee_case, misc_fees: misc_fees).tap do |c|
          c.basic_fees = basic_fees
        end
      end

      let(:basic_fees) do
        [
          build(:basic_fee, :baf_fee, :with_date_attended, rate: 4.00),
          build(:basic_fee, :baf_fee, :with_date_attended, rate: 3.00)
        ]
      end
      let(:misc_fees) { [build(:misc_fee, :miaph_fee, rate: 9.99)] }

      context 'when the case type changes to "Fixed fees"' do
        before do
          claim.case_type = build(:case_type, :fixed_fee)
          claim.fixed_fees.build attributes_for(:fixed_fee, :fxase_fee, rate: 8.00)
        end

        it { expect { call_cleaner }.not_to change(claim.fixed_fees, :size).from 1 }
        it { expect { call_cleaner }.not_to change(claim.misc_fees, :size).from 1 }
        it { expect { call_cleaner }.not_to change(claim.basic_fees, :size).from 2 }
        it { expect { call_cleaner }.to change { claim.basic_fees.flat_map(&:dates_attended).size }.from(2).to 0 }
      end
    end

    context 'with cracked trial details' do
      let(:claim) { build(:draft_claim, case_type: case_type, source: 'api', **cracked_details) }
      let(:cracked_details) do
        {
          trial_fixed_notice_at: Date.current - 3.days,
          trial_fixed_at: Date.current - 1,
          trial_cracked_at: Date.current,
          trial_cracked_at_third: 'final_third'
        }
      end

      context 'with a guilty plea' do
        let(:case_type) { create(:case_type, :guilty_plea) }

        it { expect { call_cleaner }.to change(claim, :trial_fixed_notice_at).to nil }
        it { expect { call_cleaner }.to change(claim, :trial_fixed_at).to nil }
        it { expect { call_cleaner }.to change(claim, :trial_cracked_at).to nil }
        it { expect { call_cleaner }.to change(claim, :trial_cracked_at_third).to nil }
      end

      context 'with a cracked trial' do
        let(:case_type) { create(:case_type, :cracked_trial) }

        it { expect { call_cleaner }.not_to change(claim, :trial_fixed_notice_at) }
        it { expect { call_cleaner }.not_to change(claim, :trial_fixed_at) }
        it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at) }
        it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at_third) }
      end

      context 'with a cracked before retrial trial' do
        let(:case_type) { create(:case_type, :cracked_before_retrial) }

        it { expect { call_cleaner }.not_to change(claim, :trial_fixed_notice_at) }
        it { expect { call_cleaner }.not_to change(claim, :trial_fixed_at) }
        it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at) }
        it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at_third) }
      end
    end
  end
end
