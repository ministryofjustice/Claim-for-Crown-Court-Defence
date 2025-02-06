require 'rails_helper'

RSpec.describe ClaimStateTransitionReason do
  describe '.new' do
    let(:reason) { described_class.new('code', 'short description', 'long description') }

    it { expect(reason.code).to eq('code') }
    it { expect(reason.description).to eq('short description') }
    it { expect(reason.long_description).to eq('long description') }
  end

  describe '.reasons' do
    let(:reasons) { described_class.reasons(state) }
    let(:reasons_hash) do
      {
        example_state: {
          test: {
            short: 'short description',
            long: 'long description'
          }
        }
      }
    end

    before do
      allow(described_class).to receive(:transition_reasons).and_return(reasons_hash)
    end

    context 'with an existing state' do
      let(:state) { :example_state }

      it { expect(reasons).to be_a(Array) }
      it { expect(reasons.size).to eq(1) }
      it { expect(reasons.first.code).to eq(:test) }
      it { expect(reasons.first.description).to eq('short description') }
      it { expect(reasons.first.long_description).to eq('long description') }
    end

    context 'with an unknown state' do
      let(:state) { :another_state }

      it 'raises an exception' do
        expect { reasons }.to raise_exception(described_class::StateNotFoundError)
      end
    end
  end

  describe '.reject_reasons_for' do
    subject(:reject_reasons_for) { described_class.reject_reasons_for(claim) }

    let(:agfs_reasons) do
      %w[no_indictment no_rep_order time_elapsed no_amend_rep_order case_still_live wrong_case_no wrong_maat_ref
         advocate_request rep_order_required further_clarification hardship_requirements supplemental_fee
         invalid_supplier_code soft_reject_no_response soft_reject_attendance_notes other]
    end

    let(:lgfs_reasons) do
      %w[no_indictment no_rep_order time_elapsed no_amend_rep_order case_still_live wrong_case_no wrong_maat_ref other]
    end

    let(:disbursement_only_reasons) { %w[no_prior_authority no_invoice] }

    context 'with an advocate claim' do
      let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1, amount: 21.01) }
      let(:claim) { create(:advocate_claim, :with_graduated_fee_case, basic_fees: [basic_fee], state: 'refused') }

      it 'returns base rejection reasons' do
        expect(reject_reasons_for.map(&:code)).to match_array(agfs_reasons)
      end
    end

    context 'with a Litigator interim, disbursement only claim' do
      let(:claim) { create(:interim_claim, :disbursement_only_fee, state: 'rejected') }
      let(:all_reasons) { (lgfs_reasons + disbursement_only_reasons) }

      it 'returns base rejection reasons and disbursement specific reasons' do
        expect(reject_reasons_for.map(&:code)).to match_array(all_reasons)
      end
    end

    context 'when the claim has no fees' do
      let(:claim) { build(:advocate_claim, :without_fees, state: 'rejected') }

      it 'returns base rejection reasons' do
        expect(reject_reasons_for.map(&:code)).to match_array(agfs_reasons)
      end
    end
  end

  describe '.refuse_reasons_for' do
    subject(:refuse_reasons_for) { described_class.refuse_reasons_for(claim).map(&:code) }

    context 'with a litigator final claim' do
      let(:claim) { create(:litigator_claim, :fixed_fee, fixed_fee: create(:fixed_fee, :lgfs)) }

      it { is_expected.to match_array %w[duplicate_claim other_refuse] }
    end

    context 'with a litigator transfer claim' do
      let(:claim) { create(:transfer_claim, transfer_fee: build(:transfer_fee)) }

      it { is_expected.to match_array %w[duplicate_claim other_refuse] }
    end

    context 'with a litigator interim claim' do
      let(:claim) { create(:interim_claim, interim_fee: build(:interim_fee)) }

      it do
        is_expected.to match_array %w[duplicate_claim no_effective_pcmh no_effective_trial short_trial other_refuse]
      end
    end

    context 'with an advocate final claim' do
      let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1, amount: 21.01) }
      let(:claim) { create(:advocate_claim, :with_graduated_fee_case, basic_fees: [basic_fee]) }

      it {
        is_expected.to match_array %w[wrong_ia duplicate_claim stayed_quashed_indictment predate_rep_order
                                      paid_elsewhere continuation_of_trial prescribed_proceedings
                                      incorrect_supplemental_case other_refuse]
      }
    end

    context 'with an advocate interim claim' do
      let(:claim) { create(:advocate_interim_claim) }

      it {
        is_expected.to match_array %w[duplicate_claim no_effective_pcmh no_effective_trial short_trial
                                      stayed_quashed_indictment predate_rep_order paid_elsewhere
                                      continuation_of_trial prescribed_proceedings
                                      incorrect_supplemental_case other_refuse]
      }
    end

    context 'with an advocate supplementary claim' do
      let(:claim) { create(:advocate_supplementary_claim) }

      it {
        is_expected.to match_array %w[wrong_ia duplicate_claim stayed_quashed_indictment predate_rep_order
                                      paid_elsewhere continuation_of_trial prescribed_proceedings
                                      incorrect_supplemental_case other_refuse]
      }
    end

    context 'with an advocate hardship claim' do
      let(:claim) { create(:advocate_hardship_claim) }

      it {
        is_expected.to match_array %w[wrong_ia stayed_quashed_indictment predate_rep_order paid_elsewhere
                                      continuation_of_trial prescribed_proceedings
                                      incorrect_supplemental_case]
      }
    end
  end

  describe '.get' do
    let(:code) { 'code' }
    let(:reason) { described_class.get(code) }

    context 'with an existing code' do
      before do
        allow(described_class).to receive(:description_for).with(code).and_return('description')
        allow(described_class).to receive(:description_for).with(code, :long).and_return('long description')
      end

      it { expect(reason.code).to eq('code') }
      it { expect(reason.description).to eq('description') }
      it { expect(reason.long_description).to eq('long description') }
    end

    context 'with an unknown code' do
      it 'raises an exception' do
        expect { reason }.to raise_exception(described_class::ReasonNotFoundError)
      end
    end

    context 'with an empty string code' do
      let(:code) { '' }

      it 'returns nil' do
        expect(reason).to be_nil
      end
    end

    context 'with a nil code' do
      let(:code) { nil }

      it 'returns nil' do
        expect(reason).to be_nil
      end
    end
  end

  describe '#==' do
    subject { described_class.new(code, description) }

    let(:code) { 'code1' }
    let(:description) { 'description 1' }

    context 'with the same code and description' do
      let(:other_reason) { described_class.new(code, description) }

      it { is_expected.to eq(other_reason) }
    end

    context 'with the same code and a different description' do
      let(:other_reason) { described_class.new(code, 'description 2') }

      it { is_expected.not_to eq(other_reason) }
    end

    context 'with a different code and the same description' do
      let(:other_reason) { described_class.new('code2', description) }

      it { is_expected.not_to eq(other_reason) }
    end
  end

  describe '.transition_reasons' do
    subject(:transition_reasons) { described_class.transition_reasons }

    it { is_expected.to be_a(Hash) }

    it 'returns memoized object' do
      is_expected.to equal described_class.transition_reasons
    end

    it 'returns deeply nested hash of string reasons' do
      transition_reasons.key_paths.each do |path|
        expect(transition_reasons.dig(*path)).to be_a(String)
      end
    end
  end
end
