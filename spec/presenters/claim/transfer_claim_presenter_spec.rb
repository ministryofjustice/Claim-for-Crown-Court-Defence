require 'rails_helper'

RSpec.describe Claim::TransferClaimPresenter, type: :presenter do
  let(:claim) { build(:transfer_claim) }

  subject(:presenter) { described_class.new(claim, view) }

  specify { expect(presenter.pretty_type).to eq('LGFS Transfer') }
  specify { expect(presenter.type_identifier).to eq('lgfs_transfer') }

  describe '#raw_transfer_fees_total' do
    context 'when the transfer fee is nil' do
      let(:claim) { build(:transfer_claim, transfer_fee: nil) }

      specify { expect(presenter.raw_transfer_fees_total).to eq(0) }
    end

    context 'when the transfer fee is set' do
      let(:claim) { build(:transfer_claim, transfer_fee: transfer_fee) }

      context 'but amount is not set' do
        let(:transfer_fee) { build(:transfer_fee, amount: nil) }

        specify { expect(presenter.raw_transfer_fees_total).to eq(0) }
      end

      context 'and amount is set' do
        let(:transfer_fee) { build(:transfer_fee, amount: 42.5) }

        specify { expect(presenter.raw_transfer_fees_total).to eq(42.5) }
      end
    end
  end

  describe '#display_days?' do
    subject { presenter.display_days? }

    context 'for transfer case' do
      let(:claim) { build(:transfer_claim, transfer_fee: nil) }
      it { is_expected.to be true }
    end
  end

  describe '#summary_sections' do
    specify {
      expect(presenter.summary_sections).to eq({
        transfer_detail: :transfer_fee_details,
        case_details: :case_details,
        defendants: :defendants,
        offence_details: :offence_details,
        transfer_fee: :transfer_fees,
        misc_fees: :miscellaneous_fees,
        disbursements: :disbursements,
        expenses: :travel_expenses,
        supporting_evidence: :supporting_evidence,
        additional_information: :supporting_evidence
      })
    }
  end

  describe '#conclusion_required?' do
    subject { presenter.conclusion_required? }
    let(:claim) { build(:transfer_claim, transfer_detail: detail) }

    context 'when acting is set to `Up to and including PCMH transfer`' do
      let(:detail) { build(:transfer_detail, litigator_type: 'new') }

      specify { is_expected.to eq true }
    end

    context 'when acting is set to `Transfer after trial and before sentence hearing`' do
      let(:detail) { build(:transfer_detail, litigator_type: 'new', transfer_stage_id: 40) }

      specify { is_expected.to eq false }
    end
  end

  describe 'calculate #transfer_fees' do
    before do
      allow(presenter).to receive(:raw_transfer_fees_total).and_return 10.0
      allow(claim).to receive(:created_at).and_return Date.today
      allow(claim).to receive(:apply_vat?).and_return true
    end

    it '#raw_transfer_fees_vat' do
      expect(presenter.raw_transfer_fees_vat).to eq(2.0)
    end

    it 'returns #raw_transfer_fees_gross' do
      allow(presenter).to receive(:raw_transfer_fees_vat).and_return 2.0
      expect(presenter.raw_transfer_fees_gross).to eq(12.0)
    end

    it 'returns #transfer_fees_vat with the associated currency' do
      expect(presenter.transfer_fees_vat).to eq('£2.00')
    end

    it 'returns #transfer_fees_gross with the associated currency' do
      expect(presenter.transfer_fees_gross).to eq('£12.00')
    end
  end
end
