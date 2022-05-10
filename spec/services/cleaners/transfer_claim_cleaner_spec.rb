require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::TransferClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  let(:claim) { create(:transfer_claim) }

  before do
    seed_case_types
    seed_fee_types
    seed_fee_schemes
  end

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    context 'when a graduated fee is added to the claim' do
      before { create(:graduated_fee, claim: claim) }

      it { expect { call_cleaner }.to change(claim.fees, :count).from(2).to 1 }

      it do
        call_cleaner
        expect(claim.fees.map(&:class)).to match_array([Fee::TransferFee])
      end
    end

    context 'when a valid non-graduated fee is added to the claim' do
      before { create(:misc_fee, :mispf_fee, claim: claim) }

      it { expect { call_cleaner }.not_to change(claim.fees, :count).from 2 }

      it do
        call_cleaner
        expect(claim.fees.map(&:class)).to match_array([Fee::TransferFee, Fee::MiscFee])
      end
    end

    context 'with unused materials fees' do
      subject { claim.misc_fees.map { |fee| fee.fee_type.unique_code } }

      before do
        allow(claim).to receive(:earliest_representation_order_date).and_return(Date.parse('1 January 2021'))

        create(:misc_fee, :miumu_fee, claim: claim)
        create(:misc_fee, :miumo_fee, claim: claim)

        claim.transfer_detail.update(transfer_stage_id: 10, case_conclusion_id: case_conclusion)

        call_cleaner
      end

      context 'with a guilty plea case conclusion' do
        let(:case_conclusion) { 50 }

        it { is_expected.to be_empty }
      end

      context 'with a cracked before retrial case conclusion' do
        let(:case_conclusion) { 40 }

        it { is_expected.to match_array(%w[MIUMU MIUMO]) }
      end

      context 'with a cracked case conclusion' do
        let(:case_conclusion) { 30 }

        it { is_expected.to match_array(%w[MIUMU MIUMO]) }
      end

      context 'with a retrial case conclusion' do
        let(:case_conclusion) { 20 }

        it { is_expected.to match_array(%w[MIUMU MIUMO]) }
      end

      context 'with a trial case conclusion' do
        let(:case_conclusion) { 10 }

        it { is_expected.to match_array(%w[MIUMU MIUMO]) }
      end
    end
  end
end
