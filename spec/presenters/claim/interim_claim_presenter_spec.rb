require 'rails_helper'

RSpec.describe Claim::InterimClaimPresenter, type: :presenter do
  let(:claim) { build(:interim_claim) }

  subject(:presenter) { described_class.new(claim, view) }

  specify { expect(presenter.requires_trial_dates?).to be_falsey }
  specify { expect(presenter.requires_retrial_dates?).to be_falsey }
  specify { expect(presenter.can_have_expenses?).to be_falsey }
  specify { expect(presenter.pretty_type).to eq('LGFS Interim') }
  specify { expect(presenter.type_identifier).to eq('lgfs_interim') }

  describe '#disbursement_only?' do
    context 'when there is no interim fee' do
      let(:claim) { build(:interim_claim, interim_fee: nil) }

      specify { expect(presenter.disbursement_only?).to be_falsey }
    end

    context 'when the interim fee is set' do
      let(:claim) { build(:interim_claim, interim_fee: interim_fee) }

      context 'but is not a disbursement fee' do
        let(:interim_fee) { build(:interim_fee, :effective_pcmh) }

        specify { expect(presenter.disbursement_only?).to be_falsey }
      end

      context 'and is a disbursement fee' do
        let(:interim_fee) { build(:interim_fee, :disbursement) }

        specify { expect(presenter.disbursement_only?).to be_truthy }
      end
    end
  end

  describe '#raw_interim_fees_total' do
    context 'when the interim fee is nil' do
      let(:claim) { build(:interim_claim, interim_fee: nil) }

      specify { expect(presenter.raw_interim_fees_total).to eq(0) }
    end

    context 'when the interim fee is set' do
      let(:claim) { build(:interim_claim, interim_fee: interim_fee) }

      context 'but amount is not set' do
        let(:interim_fee) { build(:interim_fee, amount: nil) }

        specify { expect(presenter.raw_interim_fees_total).to eq(0) }
      end

      context 'and amount is set' do
        let(:interim_fee) { build(:interim_fee, amount: 42.5) }

        specify { expect(presenter.raw_interim_fees_total).to eq(42.5) }
      end
    end
  end

  describe '#summary_sections' do
    specify {
      expect(presenter.summary_sections).to eq({
        case_details: :case_details,
        defendants: :defendants,
        offence_details: :offence_details,
        interim_fee: :interim_fees,
        expenses: :travel_expenses,
        supporting_evidence: :supporting_evidence,
        additional_information: :supporting_evidence
      })
    }
  end
end
