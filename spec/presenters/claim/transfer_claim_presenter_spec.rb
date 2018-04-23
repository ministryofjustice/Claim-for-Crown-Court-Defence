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

  describe '#summary_sections' do
    specify {
      expect(presenter.summary_sections).to eq(%i[transfer_detail case_details defendants offence_details transfer_fee misc_fees disbursements expenses supporting_evidence additional_information])
    }
  end
end
