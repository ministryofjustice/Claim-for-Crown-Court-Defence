require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::LitigatorHardshipClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    let(:claim) do
      create(
        :litigator_hardship_claim,
        case_stage: build(:case_stage, :pre_ptph_with_evidence)
      )
    end
    let(:hardship_fee) do
      create(
        :hardship_fee,
        claim: claim,
        date: Time.zone.today,
        quantity: 51,
        amount: 97.9
      )
    end

    it { expect { call_cleaner }.not_to change { hardship_fee.reload.quantity }.from(51) }

    context 'when changing the case_stage to "with Pre PTPH (no evidence served)"' do
      before do
        claim.case_stage = create(:case_stage, :pre_ptph_no_evidence)
      end

      it { expect { call_cleaner }.to change { hardship_fee.reload.quantity }.from(51).to(0) }
    end
  end
end
