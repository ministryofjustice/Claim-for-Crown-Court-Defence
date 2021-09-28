require 'rails_helper'

RSpec.shared_examples 'delete fixed fees' do
  it { expect { call_cleaner }.to change { claim.fixed_fees.size }.to 0 }
end

RSpec.shared_examples 'does not delete fixed fees' do
  it { expect { call_cleaner }.not_to(change { claim.fixed_fees.size }) }
end

RSpec.shared_examples 'does not delete misc fees' do
  it { expect { call_cleaner }.not_to(change { claim.misc_fees.size }) }
end

RSpec.shared_examples 'clear basic fees' do
  it { expect { call_cleaner }.not_to(change { claim.basic_fees.size }) }
  it { expect { call_cleaner }.to change { claim.basic_fees.flat_map(&:dates_attended).size }.to 0 }
end

RSpec.shared_examples 'does not clear basic fees' do
  it { expect { call_cleaner }.not_to(change { claim.basic_fees.size }) }
  it { expect { call_cleaner }.not_to(change { claim.basic_fees.flat_map(&:dates_attended).size }) }
end

RSpec.shared_examples 'clear cracked details' do
  it { expect { call_cleaner }.to change(claim, :trial_fixed_notice_at).to nil }
  it { expect { call_cleaner }.to change(claim, :trial_fixed_at).to nil }
  it { expect { call_cleaner }.to change(claim, :trial_cracked_at).to nil }
  it { expect { call_cleaner }.to change(claim, :trial_cracked_at_third).to nil }
end

RSpec.shared_examples 'does not clear cracked details' do
  it { expect { call_cleaner }.not_to change(claim, :trial_fixed_notice_at).from(cracked[:trial_fixed_notice_at]) }
  it { expect { call_cleaner }.not_to change(claim, :trial_fixed_at).from(cracked[:trial_fixed_at]) }
  it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at).from(cracked[:trial_cracked_at]) }
  it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at_third).from(cracked[:trial_cracked_at_third]) }
end

RSpec.describe Cleaners::AdvocateClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  before do
    seed_case_types
    seed_fee_types
    seed_fee_schemes
  end

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    let(:claim) do
      create(
        :advocate_final_claim, :draft,
        case_type: build(:case_type, :fixed_fee),
        fixed_fees: [create(:fixed_fee, :fxase_fee, :with_date_attended, rate: 9.99)]
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

    before do
      claim.misc_fees = [create(:misc_fee, :miaph_fee, rate: 9.99)]
      claim.basic_fees = [create(:basic_fee, :baf_fee, :with_date_attended, rate: 8.00)]
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
  end
end
