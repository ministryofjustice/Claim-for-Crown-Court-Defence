require 'rails_helper'

RSpec.describe Claim::AdvocateClaimPresenter, type: :presenter do
  let(:claim_9) { create(:advocate_claim, :agfs_scheme_9) }
  let(:claim_10) { create(:advocate_claim, :agfs_scheme_10) }
  let!(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine) }
  let!(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine) }
  let!(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme) }
  let(:claim) { claim_9 }

  subject(:presenter) { described_class.new(claim, view) }

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Final') }
  end

  describe '#type_identifier' do
    specify { expect(presenter.type_identifier).to eq('agfs_final') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end

  describe '#requires_interim_claim_info?' do
    context 'when claim is not for the AGFS fee reform scheme' do

      specify { expect(presenter.requires_interim_claim_info?).to be_falsey }
    end

    context 'when claim is for the AGFS fee reform scheme' do
      let(:claim) { claim_10 }

      specify { expect(presenter.requires_interim_claim_info?).to be_truthy }
    end
  end

  specify {
    expect(presenter.summary_sections).to eq({
      case_details: :case_details,
      defendants: :defendants,
      offence_details: :offence_details,
      basic_fees: :basic_fees,
      fixed_fees: :fixed_fees,
      misc_fees: :miscellaneous_fees,
      expenses: :travel_expenses,
      supporting_evidence: :supporting_evidence,
      additional_information: :supporting_evidence
    })
  }
end
