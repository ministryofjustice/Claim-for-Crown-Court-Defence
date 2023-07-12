require 'rails_helper'
require_relative 'shared_examples_for_lgfs_claim'

RSpec.describe Claim::LitigatorHardshipClaim do
  subject(:claim) { build(:litigator_hardship_claim) }

  it_behaves_like 'a base claim'
  it_behaves_like 'a claim with an LGFS fee scheme factory', FeeSchemeFactory::LGFS
  it_behaves_like 'a claim delegating to case type'
  it_behaves_like 'uses claim cleaner', Cleaners::LitigatorHardshipClaimCleaner

  specify { expect(claim).to be_lgfs }
  specify { expect(claim).not_to be_final }
  specify { expect(claim).not_to be_interim }
  specify { expect(claim).not_to be_supplementary }

  it { is_expected.to accept_nested_attributes_for(:hardship_fee) }
  it { is_expected.to respond_to :disable_for_state_transition }

  describe '#eligible_case_types' do
    subject { claim.eligible_case_types }

    let(:claim) { described_class.new }

    before { seed_case_types }

    it { is_expected.to all(be_a(CaseType)) }
    it { is_expected.to all(have_attributes(is_fixed_fee: false)) }
  end

  context 'with eligible misc fee types' do
    let(:claim) { build(:litigator_hardship_claim) }

    describe '#eligible_misc_fee_types' do
      subject(:call) { claim.eligible_misc_fee_types }

      let(:service) { instance_double(Claims::FetchEligibleMiscFeeTypes) }

      it 'calls eligible misc fee type fetch service' do
        expect(Claims::FetchEligibleMiscFeeTypes).to receive(:new).and_return service
        expect(service).to receive(:call)
        call
      end
    end
  end

  include_examples 'common litigator claim attributes', :hardship_claim
end
