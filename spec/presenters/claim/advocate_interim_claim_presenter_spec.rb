require 'rails_helper'

RSpec.describe Claim::AdvocateInterimClaimPresenter, type: :presenter do
  let(:claim) { build(:advocate_interim_claim) }

  subject(:presenter) { described_class.new(claim, view) }

  # TODO: Ideally this should have a
  # it_behaves_like 'a claim presenter'
  # but the spec for the base claim is quite complex to be able
  # to change that pattern. Something to address in the near future

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Warrant') }
  end

  describe '#type_identifier' do
    specify { expect(presenter.type_identifier).to eq('agfs_interim') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end

  describe '#raw_warrant_fees_total' do
    context 'when warrant fee is not set' do
      before do
        claim.warrant_fee = nil
      end

      specify { expect(presenter.raw_warrant_fees_total).to eq(0) }
    end

    context 'when warrant fee is set' do
      let(:warrant_fee) { build(:warrant_fee, amount: 50.0) }

      before do
        claim.warrant_fee = warrant_fee
      end

      specify { expect(presenter.raw_warrant_fees_total).to eq(50.0) }
    end
  end

  describe '#warrant_fees_total' do
    let(:warrant_fee) { build(:warrant_fee, amount: 32.5) }
    let(:claim) { build(:advocate_interim_claim, warrant_fee: warrant_fee) }

    it 'returns the warrant fee total with the associated currency' do
      expect(presenter.warrant_fees_total).to eq('£32.50')
    end
  end

  specify {
    expect(presenter.summary_sections).to eq({
      case_details: :case_details,
      defendants: :defendants,
      offence_details: :offence_details,
      warrant_fee: :interim_fees,
      expenses: :travel_expenses,
      supporting_evidence: :supporting_evidence,
      additional_information: :supporting_evidence
    })
  }
end
