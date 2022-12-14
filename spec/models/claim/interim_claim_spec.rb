require 'rails_helper'
require_relative 'shared_examples_for_lgfs_claim'

RSpec.describe Claim::InterimClaim do
  let(:claim) { build(:interim_claim, **options) }
  let(:options) { {} }

  it_behaves_like 'uses claim cleaner', Cleaners::InterimClaimCleaner

  it { is_expected.to delegate_method(:requires_trial_dates?).to(:case_type) }
  it { is_expected.to delegate_method(:requires_retrial_dates?).to(:case_type) }

  describe '#interim?' do
    it 'returns true' do
      expect(claim.interim?).to be true
    end
  end

  describe '#eligible_case_types' do
    let(:ct1) { create(:case_type, name: 'LGFS and Interim case type', roles: %w[lgfs interim]) }
    let(:ct2) { create(:case_type, name: 'AGFS, LGFS and Interim case type', roles: %w[agfs lgfs interim]) }
    let(:options) { { case_type: ct1 } }

    before do
      CaseType.delete_all

      create(:case_type, name: 'AGFS case type', roles: ['agfs'])
      create(:case_type, name: 'LGFS case type', roles: ['lgfs'])
      ct1
      ct2
    end

    it 'returns only Interim case types' do
      expect(claim.eligible_case_types).to contain_exactly(ct1, ct2)
    end
  end

  describe '#eligible_interim_fee_types' do
    subject { claim.eligible_interim_fee_types }

    before { allow(claim).to receive(:case_type).and_return(case_type) }

    let!(:trial_start_fee_type) { create(:interim_fee_type, :trial_start) }
    let!(:retrial_start_fee_type) { create(:interim_fee_type, :retrial_start) }

    context 'with trials' do
      let(:case_type) { instance_double(CaseType, fee_type_code: 'GRTRL') }

      it 'returns only fee types applicable for trials' do
        is_expected.to match_array [trial_start_fee_type]
      end
    end

    context 'with retrials' do
      let(:case_type) { instance_double(CaseType, fee_type_code: 'GRRTR') }

      it 'returns only fee type applicable for retrials' do
        is_expected.to match_array [retrial_start_fee_type]
      end
    end

    context 'when case_type is nil' do
      let(:case_type) { nil }

      it 'returns all interim fee type' do
        is_expected.to match_array [trial_start_fee_type, retrial_start_fee_type]
      end
    end
  end

  describe 'requires_case_type?' do
    it 'returns true' do
      expect(claim.requires_case_type?).to be true
    end
  end

  include_examples 'common litigator claim attributes'
end
