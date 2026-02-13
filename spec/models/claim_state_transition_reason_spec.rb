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
         agfs_advocate_request agfs_breach_or_appeal agfs_further_clarification agfs_hardship_requirements
         agfs_supplemental_fee agfs_invalid_supplier_code agfs_soft_reject_no_response agfs_soft_reject_attendance_notes
         other]
    end

    let(:lgfs_reasons) do
      %w[no_indictment no_rep_order time_elapsed no_amend_rep_order case_still_live wrong_case_no wrong_maat_ref
         lgfs_litigator_request lgfs_no_breakdown lgfs_no_reference lgfs_breach_or_appeal other]
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

    let(:common_lgfs_reasons) do
      %w[duplicate_claim lgfs_second_fee lgfs_unjustified_disbursement lgfs_wrong_maat_ref lgfs_proceed_of_crime_act
         lgfs_prescribed_proceedings lgfs_rep_order_not_in_place other_refuse]
    end

    let(:common_agfs_reasons) do
      %w[wrong_ia duplicate_claim agfs_stayed_quashed_indictment agfs_predate_rep_order agfs_paid_elsewhere
         agfs_continuation_of_trial agfs_prescribed_proceedings agfs_incorrect_supplemental_case other_refuse]
    end

    let(:interim_reasons) { %w[no_effective_pcmh no_effective_trial short_trial] }

    context 'with a litigator final claim' do
      let(:claim) { create(:litigator_claim, :fixed_fee, fixed_fee: create(:fixed_fee, :lgfs)) }

      it { is_expected.to match_array(common_lgfs_reasons) }
    end

    context 'with a litigator transfer claim' do
      let(:claim) { create(:transfer_claim, transfer_fee: build(:transfer_fee)) }

      it { is_expected.to match_array(common_lgfs_reasons) }
    end

    context 'with a litigator interim claim' do
      let(:claim) { create(:interim_claim, interim_fee: build(:interim_fee)) }

      it { is_expected.to match_array(common_lgfs_reasons + interim_reasons) }
    end

    context 'with a litigator hardship claim' do
      let(:claim) { create(:litigator_hardship_claim, hardship_fee: build(:hardship_fee)) }

      it { is_expected.to match_array(common_lgfs_reasons) }
    end

    context 'when a redetermination has been requested' do
      let(:common_lgfs_reasons) do
        %w[duplicate_claim lgfs_redet_second_fee lgfs_redet_unjustified_disbursement lgfs_redet_wrong_maat_ref
           lgfs_redet_proceed_of_crime_act lgfs_redet_prescribed_proceedings lgfs_redet_rep_order_not_in_place
           lgfs_redet_request_info lgfs_redet_relevance_electronic_material lgfs_redet_no_exlectronic_material
           lgfs_redet_offence_class lgfs_redet_written_reasons lgfs_redet_ppe lgfs_redet_incorrect_case_type
           other_refuse]
      end

      before { claim.allocate! }

      context 'with a litigator final claim' do
        let(:claim) { create(:litigator_claim, :fixed_fee, :redetermination, fixed_fee: create(:fixed_fee, :lgfs)) }

        it { is_expected.to match_array(common_lgfs_reasons) }
      end

      context 'with a litigator transfer claim' do
        let(:claim) { create(:transfer_claim, :redetermination, transfer_fee: build(:transfer_fee)) }

        it { is_expected.to match_array(common_lgfs_reasons) }
      end

      context 'with a litigator interim claim' do
        let(:claim) { create(:interim_claim, :redetermination, interim_fee: build(:interim_fee)) }

        it { is_expected.to match_array(common_lgfs_reasons + interim_reasons) }
      end

      context 'with a litigator hardship claim' do
        let(:claim) { create(:litigator_hardship_claim, :redetermination, hardship_fee: build(:hardship_fee)) }

        it { is_expected.to match_array(common_lgfs_reasons) }
      end
    end

    context 'when written reasons have been requested' do
      let(:common_lgfs_reasons) do
        %w[duplicate_claim lgfs_redet_second_fee lgfs_redet_unjustified_disbursement lgfs_redet_wrong_maat_ref
           lgfs_redet_proceed_of_crime_act lgfs_redet_prescribed_proceedings lgfs_redet_rep_order_not_in_place
           lgfs_redet_request_info lgfs_redet_relevance_electronic_material lgfs_redet_no_exlectronic_material
           lgfs_redet_offence_class lgfs_redet_written_reasons lgfs_redet_ppe lgfs_redet_incorrect_case_type
           other_refuse]
      end

      before { claim.allocate! }

      context 'with a litigator final claim' do
        let(:claim) do
          create(:litigator_claim, :fixed_fee, :awaiting_written_reasons, fixed_fee: create(:fixed_fee, :lgfs))
        end

        it { is_expected.to match_array(common_lgfs_reasons) }
      end

      context 'with a litigator transfer claim' do
        let(:claim) { create(:transfer_claim, :awaiting_written_reasons, transfer_fee: build(:transfer_fee)) }

        it { is_expected.to match_array(common_lgfs_reasons) }
      end

      context 'with a litigator interim claim' do
        let(:claim) { create(:interim_claim, :awaiting_written_reasons, interim_fee: build(:interim_fee)) }

        it { is_expected.to match_array(common_lgfs_reasons + interim_reasons) }
      end

      context 'with a litigator hardship claim' do
        let(:claim) { create(:litigator_hardship_claim, :awaiting_written_reasons, hardship_fee: build(:hardship_fee)) }

        it { is_expected.to match_array(common_lgfs_reasons) }
      end
    end

    context 'with an advocate final claim' do
      let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1, amount: 21.01) }
      let(:claim) { create(:advocate_claim, :with_graduated_fee_case, basic_fees: [basic_fee]) }

      it { is_expected.to match_array(common_agfs_reasons) }
    end

    context 'with an advocate interim claim' do
      let(:claim) { create(:advocate_interim_claim) }

      it { is_expected.to match_array(common_agfs_reasons + interim_reasons - ['wrong_ia']) }
    end

    context 'with an advocate supplementary claim' do
      let(:claim) { create(:advocate_supplementary_claim) }

      it { is_expected.to match_array(common_agfs_reasons) }
    end

    context 'with an advocate hardship claim' do
      let(:claim) { create(:advocate_hardship_claim) }

      it { is_expected.to match_array(common_agfs_reasons - %w[duplicate_claim other_refuse]) }
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
      # E.g. disbursement -> no_prior_authority -> short -> message = "No prior authority provided"
      expect(transition_reasons.values.flat_map(&:values).flat_map(&:values)).to all(be_a(String))
    end
  end
end
