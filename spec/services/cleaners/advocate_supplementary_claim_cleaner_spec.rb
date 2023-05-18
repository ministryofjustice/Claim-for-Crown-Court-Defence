require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::AdvocateSupplementaryClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    let(:claim) { create(:advocate_supplementary_claim, with_misc_fee: false) }
    let(:misc_fee) { build(:misc_fee, :mispf_fee) }

    before do
      seed_fee_types

      claim.misc_fees << misc_fee
    end

    context 'with an eligible fee; Special preparation fee (MISPF)' do
      let(:misc_fee) { build(:misc_fee, :mispf_fee) }

      it { expect { call_cleaner }.not_to change { claim.misc_fees.size }.from(1) }
    end

    context 'with an ineligible fee; Noting brief fee (MINBR)' do
      let(:misc_fee) { build(:misc_fee, :minbr_fee) }

      it { expect { call_cleaner }.to change { claim.misc_fees.size }.by(-1) }
    end

    include_examples 'fix advocate category'
  end
end
