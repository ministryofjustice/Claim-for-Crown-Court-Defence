require 'rails_helper'

RSpec.describe Claim::AdvocateClaimPresenter, type: :presenter do
  let(:claim_9) { create(:advocate_claim, :agfs_scheme_9) }
  let(:claim_10) { create(:advocate_claim, :agfs_scheme_10) }
  let!(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs) }
  let!(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine) }
  let!(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme) }
  let(:claim) { claim_9 }
  let(:discontinuance) { create(:case_type, :discontinuance) }
  let(:claim_discontinuance_9) { create(:advocate_claim, :agfs_scheme_9, case_type: discontinuance, prosecution_evidence: true) }
  let(:claim_discontinuance_10) { create(:advocate_claim, :agfs_scheme_10, case_type: discontinuance, prosecution_evidence: true) }

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

  describe '#display_prosecution_evidence?' do
    context 'when claim is not for the AGFS fee reform scheme' do
      context 'when claim is a discontinuance' do
        let(:claim) { claim_discontinuance_9 }
        specify { expect(presenter.display_prosecution_evidence?).to be false }
      end
      
      context 'when claim is not a discontinuance' do
        let(:claim) { claim_9 }
        specify { expect(presenter.display_prosecution_evidence?).to be false }
      end
    end

    context 'when claim is for the AGFS fee reform scheme' do
      context 'when claim is a discontinuance' do
        let(:claim) { claim_discontinuance_10 }
        specify { expect(presenter.display_prosecution_evidence?).to be true }
      end

      context 'when claim is not a discontinuance' do
        let(:claim) { claim_10 }
        specify { expect(presenter.display_prosecution_evidence?).to be false }
      end
    end
  end

  describe '#any_prosecution_evidence' do
    context 'when display_prosecution_evidence is true' do
      let(:claim) { claim_discontinuance_10 }
      specify{ expect(presenter.any_prosecution_evidence).to eql 'Yes' }
    end
  
    context 'when display_prosecution_evidence is false' do
      let(:claim) { claim_10 }
      specify{ expect(presenter.any_prosecution_evidence).to eql 'No' }
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
