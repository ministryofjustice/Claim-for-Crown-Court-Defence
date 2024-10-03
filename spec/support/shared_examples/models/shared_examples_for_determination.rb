# frozen_string_literal: true

RSpec.shared_examples 'numeric fields in determinations' do
  context 'with a litigator claim' do
    let(:claim) { create(:litigator_claim) }

    context 'when the fees parameter has a comma' do
      let(:params) { { fees: '1,000,000' } }

      it { expect(subject.fees).to eq 1_000_000 }
    end

    context 'when the expenses parameter has a comma' do
      let(:params) { { expenses: '1,000,000' } }

      it { expect(subject.expenses).to eq 1_000_000 }
    end

    context 'when the disbursements parameter has a comma' do
      let(:params) { { disbursements: '1,000,000' } }

      it { expect(subject.disbursements).to eq 1_000_000 }
    end

    context 'when the vat_amount parameter has a comma' do
      let(:params) { { vat_amount: '1,000,000' } }

      it { expect(subject.vat_amount).to eq 1_000_000 }
    end
  end

  context 'with an advocate claim' do
    let(:claim) { create(:advocate_claim) }

    context 'when the fees parameter has a comma' do
      let(:params) { { fees: '1,000,000' } }

      it { expect(subject.fees).to eq 1_000_000 }
    end

    context 'when the expenses parameter has a comma' do
      let(:params) { { expenses: '1,000,000' } }

      it { expect(subject.expenses).to eq 1_000_000 }
    end

    context 'when the disbursements parameter has a comma' do
      let(:params) { { disbursements: '1,000,000' } }

      it { expect(subject.disbursements).to eq 1_000_000 }
    end

    context 'when the vat_amount parameter is explicitly set' do
      let(:params) { { fees: 2121, vat_amount: '1,000,000' } }

      it { expect(subject.vat_amount).to eq 424.20 }
    end
  end
end
