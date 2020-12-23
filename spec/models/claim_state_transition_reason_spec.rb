require 'rails_helper'

RSpec.describe ClaimStateTransitionReason, type: :model do
  describe '.new' do
    let(:reason) { described_class.new('code', 'short description', 'long description') }

    it 'initialize a reason object with provided code and description' do
      expect(reason.code).to eq('code')
      expect(reason.description).to eq('short description')
      expect(reason.long_description).to eq('long description')
    end
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

    context 'for an existing state' do
      let(:state) { :example_state }

      it 'returns a collection of reason objects for the given state' do
        expect(reasons).to be_kind_of(Array)
        expect(reasons.size).to eq(1)
        expect(reasons.first.code).to eq(:test)
        expect(reasons.first.description).to eq('short description')
        expect(reasons.first.long_description).to eq('long description')
      end
    end

    context 'for an unknown state' do
      let(:state) { :another_state }

      it 'raises an exception' do
        expect { reasons }.to raise_exception(ClaimStateTransitionReason::StateNotFoundError)
      end
    end
  end

  describe '.reject_reasons_for' do
    subject(:reject_reasons_for) { described_class.reject_reasons_for(claim) }
    let(:reasons) { %w[no_indictment no_rep_order time_elapsed no_amend_rep_order case_still_live wrong_case_no wrong_maat_ref other] }
    let(:disbursement_only_reasons) { %w[no_prior_authority no_invoice] }
    let(:all_reasons) { (reasons + disbursement_only_reasons) }

    context 'for an advocate claim' do
      let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1, amount: 21.01) }
      let(:claim) { create(:advocate_claim, :with_graduated_fee_case, basic_fees: [basic_fee], state: 'refused') }

      it 'returns base rejection reasons' do
        expect(reject_reasons_for.map(&:code)).to match_array(reasons)
      end
    end

    context 'for a Litigator interim, disbursement only claim' do
      let(:claim) { create(:interim_claim, :disbursement_only_fee, state: 'rejected') }

      it 'returns base rejection reasons and disbursement specific reasons' do
        expect(reject_reasons_for.map(&:code)).to match_array(all_reasons)
      end
    end

    context 'when the claim has no fees' do
      let(:claim) { build(:advocate_claim, :without_fees, state: 'rejected') }

      it 'returns base rejection reasons' do
        expect(reject_reasons_for.map(&:code)).to match_array(reasons)
      end
    end
  end

  describe '.refuse_reasons_for' do
    subject(:refuse_reasons_for) { described_class.refuse_reasons_for(claim).map(&:code) }

    context 'for a litigator final claim' do
      let(:claim) { create(:litigator_claim, :fixed_fee, fixed_fee: create(:fixed_fee, :lgfs)) }

      it { is_expected.to match_array %w[duplicate_claim other_refuse] }
    end

    context 'for a litigator transfer claim' do
      let(:claim) { create(:transfer_claim, transfer_fee: build(:transfer_fee)) }

      it { is_expected.to match_array %w[duplicate_claim other_refuse] }
    end

    context 'for a litigator interim claim' do
      let(:claim) { create(:interim_claim, interim_fee: build(:interim_fee)) }

      it { is_expected.to match_array %w[duplicate_claim no_effective_pcmh no_effective_trial short_trial other_refuse] }
    end

    context 'for an advocate final claim' do
      let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1, amount: 21.01) }
      let(:claim) { create(:advocate_claim, :with_graduated_fee_case, basic_fees: [basic_fee]) }

      it { is_expected.to match_array %w[wrong_ia duplicate_claim other_refuse] }
    end

    context 'for an advocate interim claim' do
      let(:claim) { create(:advocate_interim_claim) }

      it { is_expected.to match_array %w[duplicate_claim no_effective_pcmh no_effective_trial short_trial other_refuse] }
    end

    context 'for an advocate supplementary claim' do
      let(:claim) { create(:advocate_supplementary_claim) }

      it { is_expected.to match_array %w[wrong_ia duplicate_claim other_refuse] }
    end
  end

  describe '.get' do
    let(:code) { 'code' }
    let(:reason) { described_class.get(code) }

    context 'for an existing code' do
      before do
        allow(described_class).to receive(:description_for).with(code).and_return('description')
        allow(described_class).to receive(:description_for).with(code, :long).and_return('long description')
      end

      it 'initializes and retrieve a reason object if code exists' do
        expect(reason.code).to eq('code')
        expect(reason.description).to eq('description')
        expect(reason.long_description).to eq('long description')
      end
    end

    context 'for an unknown code' do
      it 'raises an exception' do
        expect { reason }.to raise_exception(ClaimStateTransitionReason::ReasonNotFoundError)
      end
    end

    context 'for an empty string code' do
      let(:code) { '' }

      it 'returns nil' do
        expect(reason).to be_nil
      end
    end

    context 'for a nil code' do
      let(:code) { nil }

      it 'returns nil' do
        expect(reason).to be_nil
      end
    end
  end

  describe '#==' do
    let(:reason_1) { described_class.new('code1', 'description 1') }
    let(:reason_2) { described_class.new('code1', 'description 1') }
    let(:reason_3) { described_class.new('code1', 'description 3') }

    it 'considers as equal two reasons with the same reason code and description' do
      expect(reason_1).to eq(reason_2)
    end

    it 'considers as different two reasons with different reason codes or different descriptions' do
      expect(reason_1).not_to eq(reason_3)
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
