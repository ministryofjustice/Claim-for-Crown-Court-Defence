require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.shared_examples 'delete fixed fees' do
  it { expect { call_cleaner }.to change { claim.fixed_fees.size }.to 0 }
end

RSpec.shared_examples 'does not delete fixed fees' do
  it { expect { call_cleaner }.not_to change { claim.fixed_fees.size } }
end

RSpec.shared_examples 'does not delete misc fees' do
  it { expect { call_cleaner }.not_to change { claim.misc_fees.size } }
end

RSpec.shared_examples 'clear basic fees' do
  it { expect { call_cleaner }.not_to change { claim.basic_fees.size } }
  it { expect { call_cleaner }.to change { claim.basic_fees.flat_map(&:dates_attended).size }.to 0 }
  it { expect { call_cleaner }.to change { claim.basic_fees.sum { |fee| fee.amount.to_i } }.to 0 }
end

RSpec.shared_examples 'does not clear basic fees' do
  it { expect { call_cleaner }.not_to change { claim.basic_fees.flat_map(&:dates_attended).size } }
  it { expect { call_cleaner }.not_to change { claim.basic_fees.sum(&:amount) }.from(within(0.01).of(basic_fee_rate)) }
end

RSpec.describe Cleaners::AdvocateClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  before do
    seed_case_types
    seed_fee_types
  end

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    let(:claim) do
      create(
        :advocate_final_claim, :draft,
        case_type: build(:case_type, :fixed_fee),
        fixed_fees: create_list(:fixed_fee, 1, :fxase_fee, :with_date_attended, rate: 9.99)
      )
    end

    let(:cracked) do
      {
        trial_fixed_notice_at: Date.current - 3.days,
        trial_fixed_at: Date.current - 1,
        trial_cracked_at: Date.current,
        trial_cracked_at_third: 'final_third'
      }
    end

    let(:basic_fee_rate) { 99.99 }
    let(:case_type) { build(:case_type, :trial) }

    before do
      claim.misc_fees = create_list(:misc_fee, 1, :miaph_fee, rate: 9.99)
      claim.basic_fees = create_list(:basic_fee, 1, :baf_fee, :with_date_attended, rate: basic_fee_rate)
      claim.trial_fixed_notice_at = cracked[:trial_fixed_notice_at]
      claim.trial_fixed_at = cracked[:trial_fixed_at]
      claim.trial_cracked_at = cracked[:trial_cracked_at]
      claim.trial_cracked_at_third = cracked[:trial_cracked_at_third]
      claim.case_type = case_type
    end

    context 'with an "Appeal against conviction" claim' do
      let(:case_type) { build(:case_type, :appeal_against_conviction) }

      include_examples 'delete fixed fees'
      include_examples 'does not delete misc fees'
      include_examples 'clear basic fees'
      include_examples 'clear cracked details'
    end

    context 'with a "Trial" claim' do
      let(:case_type) { build(:case_type, :trial) }

      include_examples 'delete fixed fees'
      include_examples 'does not delete misc fees'
      include_examples 'does not clear basic fees'
      include_examples 'clear cracked details'
    end

    context 'with a "Fixed fees" claim' do
      let(:case_type) { build(:case_type, :fixed_fee) }

      include_examples 'does not delete fixed fees'
      include_examples 'does not delete misc fees'
      include_examples 'clear basic fees'
      include_examples 'clear cracked details'
    end

    context 'with a "Guilty plea" claim' do
      let(:case_type) { build(:case_type, :guilty_plea) }

      include_examples 'delete fixed fees'
      include_examples 'does not delete misc fees'
      include_examples 'does not clear basic fees'
      include_examples 'clear cracked details'
    end

    context 'with a "Cracked" claim' do
      let(:case_type) { build(:case_type, :cracked_trial) }

      include_examples 'delete fixed fees'
      include_examples 'does not delete misc fees'
      include_examples 'does not clear basic fees'
      include_examples 'does not clear cracked details'
    end

    context 'with a "Cracked before retrial" claim' do
      let(:case_type) { build(:case_type, :cracked_before_retrial) }

      include_examples 'delete fixed fees'
      include_examples 'does not delete misc fees'
      include_examples 'does not clear basic fees'
      include_examples 'does not clear cracked details'
    end

    include_examples 'fix advocate category'
  end
end
