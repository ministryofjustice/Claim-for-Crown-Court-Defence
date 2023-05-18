require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::AdvocateHardshipClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    let(:claim) { create(:advocate_hardship_claim) }

    let(:cracked) do
      {
        trial_fixed_notice_at: Date.current - 3.days,
        trial_fixed_at: Date.current - 1,
        trial_cracked_at: Date.current,
        trial_cracked_at_third: 'final_third'
      }
    end

    let(:case_stage) { create(:case_stage, :cracked_trial) }

    before do
      claim.trial_fixed_notice_at = cracked[:trial_fixed_notice_at]
      claim.trial_fixed_at = cracked[:trial_fixed_at]
      claim.trial_cracked_at = cracked[:trial_cracked_at]
      claim.trial_cracked_at_third = cracked[:trial_cracked_at_third]
      claim.case_stage = case_stage
    end

    context 'with a "guilty plea (not yet sentenced)" claim' do
      let(:case_stage) { create(:case_stage, :guilty_plea_not_sentenced) }

      include_examples 'clear cracked details'
    end

    context 'with a "cracked trial (After PTPH before trial)" claim' do
      let(:case_stage) { create(:case_stage, :cracked_trial) }

      include_examples 'does not clear cracked details'
    end

    context 'with cracked before retrial (Retrial listed but not started)' do
      let(:case_stage) { create(:case_stage, :retrial_not_started) }

      include_examples 'does not clear cracked details'
    end

    include_examples 'fix advocate category'
  end
end
