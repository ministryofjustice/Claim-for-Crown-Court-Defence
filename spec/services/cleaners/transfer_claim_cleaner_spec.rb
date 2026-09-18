require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::TransferClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  let(:claim) { create(:transfer_claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    context 'when a graduated fee is added to the claim' do
      before { create(:graduated_fee, claim:) }

      it 'removes the graduated fee and leaves only the transfer fee' do
        call_cleaner

        aggregate_failures do
          expect(claim.fees.count).to eq(1)
          expect(claim.fees.map(&:class)).to contain_exactly(Fee::TransferFee)
        end
      end
    end

    context 'when a non-graduated fee is added to the claim' do
      before { create(:misc_fee, claim:) }

      it 'keeps the transfer fee and misc fee when a non-graduated fee is added' do
        call_cleaner

        aggregate_failures do
          expect(claim.fees.count).to eq(2)
          expect(claim.fees.map(&:class)).to contain_exactly(Fee::TransferFee, Fee::MiscFee)
        end
      end
    end
  end
end
