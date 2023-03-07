require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::TransferClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  let(:claim) { create(:transfer_claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    context 'when a graduated fee is added to the claim' do
      before { create(:graduated_fee, claim:) }

      it { expect { call_cleaner }.to change(claim.fees, :count).from(2).to 1 }

      it do
        call_cleaner
        expect(claim.fees.map(&:class)).to contain_exactly(Fee::TransferFee)
      end
    end

    context 'when a non-graduated fee is added to the claim' do
      before { create(:misc_fee, claim:) }

      it { expect { call_cleaner }.not_to change(claim.fees, :count).from 2 }

      it do
        call_cleaner
        expect(claim.fees.map(&:class)).to contain_exactly(Fee::TransferFee, Fee::MiscFee)
      end
    end
  end
end
