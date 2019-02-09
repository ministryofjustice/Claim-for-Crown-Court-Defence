require 'rails_helper'

RSpec.describe Claim::AdvocateSupplementaryClaimPresenter, type: :presenter do
  let(:claim) { build(:advocate_supplementary_claim) }

  subject(:presenter) { described_class.new(claim, view) }

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Supplementary') }
  end

  describe '#type_identifier' do
    specify { expect(presenter.type_identifier).to eq('agfs_supplementary') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end

  describe '#misc_fees_total' do
    let(:claim) do
      create(:advocate_supplementary_claim).tap do |claim|
        claim.fees << create(:misc_fee, :mispf_fee, claim: claim, rate: 131.00, quantity: 2)
      end
    end

    it 'returns the misc fees total with the associated currency' do
      expect(presenter.misc_fees_total).to eq('£287.00')
    end
  end

  specify {
    expect(presenter.summary_sections).to eq({
      case_details: :case_details,
      defendants: :defendants,
      misc_fees: :miscellaneous_fees,
      expenses: :travel_expenses,
      supporting_evidence: :supporting_evidence,
      additional_information: :supporting_evidence
    })
  }
end
