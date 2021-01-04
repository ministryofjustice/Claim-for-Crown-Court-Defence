require 'rails_helper'
require_relative 'shared_examples_for_lgfs_claim'

RSpec.describe Claim::LitigatorHardshipClaim, type: :model do
  let(:claim) { build :litigator_hardship_claim }

  it_behaves_like 'a base claim'

  specify { expect(subject.lgfs?).to be_truthy }
  specify { expect(subject.final?).to be_falsey }
  specify { expect(subject.interim?).to be_falsey }
  specify { expect(subject.supplementary?).to be_falsey }

  it { is_expected.to accept_nested_attributes_for(:hardship_fee) }

  describe '#eligible_case_types' do
    subject { claim.eligible_case_types }

    let(:claim) { described_class.new }

    before { seed_case_types }

    it { is_expected.to all(be_a(CaseType)) }
    it { is_expected.to all(have_attributes(is_fixed_fee: false)) }
  end

  context 'eligible misc fee types' do
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

  describe '#cleaner' do
    context 'when the hardship fee has ppe' do
      let!(:hardship_fee) { create :hardship_fee, claim: claim, date: Date.today, quantity: 51, amount: 97.9 }
      let!(:claim) { create(:litigator_hardship_claim, case_stage: create(:case_stage, :pre_ptph_with_evidence)) }

      context 'with guilty plea' do
        it 'leaves the quantity intact' do
          expect(hardship_fee.quantity).to eq 51
        end
      end

      context 'when the case_stage is changed to `with Pre PTPH (no evidence served)`' do
        let(:no_evidence_case_stage) { create(:case_stage, :pre_ptph_no_evidence) }

        before do
          claim.update(case_stage: no_evidence_case_stage)
          claim.save
        end

        it 'leaves the quantity intact' do
          expect(hardship_fee.reload.quantity).to eq 0
        end
      end
    end
  end

  include_examples 'common litigator claim attributes', :hardship_claim
end
