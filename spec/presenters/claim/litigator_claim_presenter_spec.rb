require 'rails_helper'

RSpec.describe Claim::LitigatorClaimPresenter, type: :presenter do
  let(:claim) { build(:litigator_claim) }

  subject(:presenter) { described_class.new(claim, view) }

  specify { expect(presenter.pretty_type).to eq('LGFS Final') }
  specify { expect(presenter.type_identifier).to eq('lgfs_final') }

  describe '#fixed_fees' do
    context 'when the fixed fee is nil' do
      let(:claim) { build(:litigator_claim, fixed_fee: nil) }

      specify { expect(presenter.fixed_fees).to be_empty }
    end

    context 'when the fixed fee is set' do
      let(:fixed_fee) { build(:fixed_fee) }
      let(:claim) { build(:litigator_claim, fixed_fee: fixed_fee) }

      specify { expect(presenter.fixed_fees).to eq([fixed_fee]) }
    end
  end

  describe '#raw_fixed_fees_total' do
    context 'when the fixed fee is nil' do
      let(:claim) { build(:litigator_claim, fixed_fee: nil) }

      specify { expect(presenter.raw_fixed_fees_total).to eq(0) }
    end

    context 'when the fixed fee is set' do
      let(:claim) { build(:litigator_claim, fixed_fee: fixed_fee) }

      context 'but amount is not set' do
        let(:fixed_fee) { build(:fixed_fee, amount: nil) }

        specify { expect(presenter.raw_fixed_fees_total).to eq(0) }
      end

      context 'and amount is set' do
        let(:fixed_fee) { build(:fixed_fee, amount: 42.5) }

        specify { expect(presenter.raw_fixed_fees_total).to eq(42.5) }
      end
    end
  end

  describe '#raw_grad_fees_total' do
    context 'when the graduated fee is nil' do
      let(:claim) { build(:litigator_claim, graduated_fee: nil) }

      specify { expect(presenter.raw_grad_fees_total).to eq(0) }
    end

    context 'when the graduated fee is set' do
      let(:claim) { build(:litigator_claim, graduated_fee: graduated_fee) }

      context 'but amount is not set' do
        let(:graduated_fee) { build(:graduated_fee, amount: nil) }

        specify { expect(presenter.raw_grad_fees_total).to eq(0) }
      end

      context 'and amount is set' do
        let(:graduated_fee) { build(:graduated_fee, amount: 42.5) }

        specify { expect(presenter.raw_grad_fees_total).to eq(42.5) }
      end
    end
  end

  describe '#raw_warrant_fees_total' do
    context 'when the warrant fee is nil' do
      let(:claim) { build(:litigator_claim, warrant_fee: nil) }

      specify { expect(presenter.raw_warrant_fees_total).to eq(0) }
    end

    context 'when the warrant fee is set' do
      let(:claim) { build(:litigator_claim, warrant_fee: warrant_fee) }

      context 'but amount is not set' do
        let(:warrant_fee) { build(:warrant_fee, amount: nil) }

        specify { expect(presenter.raw_warrant_fees_total).to eq(0) }
      end

      context 'and amount is set' do
        let(:warrant_fee) { build(:warrant_fee, amount: 42.5) }

        specify { expect(presenter.raw_warrant_fees_total).to eq(42.5) }
      end
    end
  end

  describe '#summary_sections' do
    specify {
      expect(presenter.summary_sections).to eq(%i[case_details defendants offence_details fixed_fees graduated_fees misc_fees disbursements expenses supporting_evidence additional_information])
    }
  end
end
