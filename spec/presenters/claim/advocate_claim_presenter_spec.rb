require 'rails_helper'

RSpec.describe Claim::AdvocateClaimPresenter, type: :presenter do
  subject(:presenter) { described_class.new(claim, view) }

  let(:claim_9) { create(:advocate_claim, :agfs_scheme_9) }
  let(:claim_10) { create(:advocate_claim, :agfs_scheme_10) }
  let!(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs) }
  let!(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine) }
  let!(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme) }
  let(:claim) { claim_9 }
  let(:discontinuance) { create(:case_type, :discontinuance) }
  let(:claim_discontinuance_9) { create(:advocate_claim, :agfs_scheme_9, case_type: discontinuance, prosecution_evidence: true) }
  let(:claim_discontinuance_10) { create(:advocate_claim, :agfs_scheme_10, case_type: discontinuance, prosecution_evidence: true) }

  it { is_expected.to be_kind_of(Claim::BaseClaimPresenter) }

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Final') }
  end

  describe '#type_identifier' do
    specify { expect(presenter.type_identifier).to eq('agfs_final') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end

  describe '#can_have_expenses?' do
    specify { expect(presenter.can_have_expenses?).to be_truthy }
  end

  describe '#requires_interim_claim_info?' do
    subject { presenter.requires_interim_claim_info? }

    before { seed_fee_schemes }

    context 'when claim is pre agfs reform' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }
      it { is_expected.to be_falsey }
    end

    context 'when claim is post agfs reform' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }
      it { is_expected.to be_truthy }
    end
  end

  describe '#raw_basic_fees_total' do
    it 'sends message to claim' do
      expect(claim).to receive(:calculate_fees_total).with(:basic_fees)
      presenter.raw_basic_fees_total
    end
  end

  describe '#raw_fixed_fees_total' do
    it 'sends message to claim' do
      expect(claim).to receive(:calculate_fees_total).with(:fixed_fees)
      presenter.raw_fixed_fees_total
    end
  end

  describe '#raw_fixed_fees_combined_total' do
    it 'sends messages to self' do
      expect(presenter.raw_fixed_fees_combined_total). to be_kind_of(BigDecimal)
    end
  end

  describe 'calculate #fixed_fees' do
    before do
      allow(presenter).to receive(:raw_fixed_fees_total).and_return 10.0
      allow(claim).to receive(:created_at).and_return Date.today
      allow(claim).to receive(:apply_vat?).and_return true
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
