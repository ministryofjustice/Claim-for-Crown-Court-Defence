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
      let(:claim) { build(:litigator_claim, fixed_fee:) }

      specify { expect(presenter.fixed_fees).to eq([fixed_fee]) }
    end
  end

  describe '#raw_fixed_fees_total' do
    context 'when the fixed fee is nil' do
      let(:claim) { build(:litigator_claim, fixed_fee: nil) }

      specify { expect(presenter.raw_fixed_fees_total).to eq(0) }
    end

    context 'when the fixed fee is set' do
      let(:claim) { build(:litigator_claim, fixed_fee:) }

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

  describe '#display_days?' do
    subject { presenter.display_days? }

    context 'for a fixed fee case' do
      let(:claim) { build(:litigator_claim, :with_fixed_fee_case) }

      it { is_expected.to be false }
    end

    context 'for non-fixed fee case' do
      let(:claim) { build(:litigator_claim, :with_graduated_fee_case) }

      it { is_expected.to be true }
    end
  end

  describe '#raw_grad_fees_total' do
    context 'when the graduated fee is nil' do
      let(:claim) { build(:litigator_claim, graduated_fee: nil) }

      specify { expect(presenter.raw_grad_fees_total).to eq(0) }
    end

    context 'when the graduated fee is set' do
      let(:claim) { build(:litigator_claim, graduated_fee:) }

      context 'but amount is not set' do
        let(:graduated_fee) { build(:graduated_fee, amount: nil) }

        specify { expect(presenter.raw_grad_fees_total).to eq(0) }
      end

      context 'and amount is set' do
        let(:graduated_fee) { build(:graduated_fee, amount: 42.5) }

        specify { expect(presenter.raw_grad_fees_total).to eq(42.5) }
        specify { expect(presenter.display_days?).to be true }
      end
    end
  end

  describe '#raw_warrant_fees_total' do
    context 'when the warrant fee is nil' do
      let(:claim) { build(:litigator_claim, warrant_fee: nil) }

      specify { expect(presenter.raw_warrant_fees_total).to eq(0) }
    end

    context 'when the warrant fee is set' do
      let(:claim) { build(:litigator_claim, warrant_fee:) }

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

  describe '#requires_interim_claim_info?' do
    specify { expect(presenter.requires_interim_claim_info?).to be_truthy }
  end

  describe '#requires_trial_dates?' do
    specify { expect(presenter.requires_trial_dates?).to be false }
  end

  describe 'calculate #fixed_fees' do
    before do
      allow(presenter).to receive(:raw_fixed_fees_total).and_return 10.0
      allow(claim).to receive_messages(created_at: Time.zone.today, apply_vat?: true)
    end

    it '#raw_fixed_fees_vat' do
      expect(presenter.raw_fixed_fees_vat).to eq(2.0)
    end

    it 'returns #raw_fixed_fees_gross' do
      allow(presenter).to receive(:raw_fixed_fees_vat).and_return 2.0
      expect(presenter.raw_fixed_fees_gross).to eq(12.0)
    end

    it 'returns #fixed_fees_vat with the associated currency' do
      expect(presenter.fixed_fees_vat).to eq('£2.00')
    end

    it 'returns #fixed_fees_gross with the associated currency' do
      expect(presenter.fixed_fees_gross).to eq('£12.00')
    end
  end

  describe 'calculate #warrant_fees' do
    before do
      allow(presenter).to receive(:raw_warrant_fees_total).and_return 10.0
      allow(claim).to receive_messages(created_at: Time.zone.today, apply_vat?: true)
    end

    it '#raw_warrant_fees_vat' do
      expect(presenter.raw_warrant_fees_vat).to eq(2.0)
    end

    it 'returns #raw_warrant_fees_gross' do
      allow(presenter).to receive(:raw_warrant_fees_vat).and_return 2.0
      expect(presenter.raw_warrant_fees_gross).to eq(12.0)
    end

    it 'returns #warrant_fees_vat with the associated currency' do
      expect(presenter.warrant_fees_vat).to eq('£2.00')
    end

    it 'returns #warrant_fees_gross with the associated currency' do
      expect(presenter.warrant_fees_gross).to eq('£12.00')
    end
  end

  describe '#summary_sections' do
    specify {
      expect(presenter.summary_sections).to eq(
        {
          case_details: :case_details,
          defendants: :defendants,
          offence_details: :offence_details,
          fixed_fees: :fixed_fees,
          graduated_fees: :graduated_fees,
          misc_fees: :miscellaneous_fees,
          disbursements: :disbursements,
          expenses: :travel_expenses,
          supporting_evidence: :supporting_evidence,
          additional_information: :supporting_evidence
        }
      )
    }
  end

  describe '#disbursements_total' do
    let(:claim) { create(:claim, disbursements_total: 1.346) }

    it 'returns the disbursements total rounded and formatted' do
      expect(subject.disbursements_total).to eq('£1.35')
    end
  end

  describe '#case_concluded_at' do
    let(:claim) { create(:claim, case_concluded_at: Time.utc(2014, 12, 31, 20, 15)) }

    it 'returns the case_concluded_at formatted' do
      expect(subject.case_concluded_at).to eq('31/12/2014')
    end
  end

  it 'has disbursements' do
    expect(subject.can_have_disbursements?).to be(true)
  end
end
