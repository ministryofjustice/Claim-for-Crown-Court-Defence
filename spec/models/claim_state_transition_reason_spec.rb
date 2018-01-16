require 'rails_helper'

RSpec.describe ClaimStateTransitionReason, type: :model do

  describe '.new' do
    let(:reason) { described_class.new('code', 'description') }

    it 'initialize a reason object with provided code and description' do
      expect(reason.code).to eq('code')
      expect(reason.description).to eq('description')
    end
  end

  describe '.reasons' do
    let(:reasons) { described_class.reasons(state) }
    let(:reasons_hash) { {example_state: {test: 'description'}} }

    before do
      allow(described_class).to receive(:reasons_map).and_return(reasons_hash)
    end

    context 'for an existing state' do
      let(:state) { :example_state }

      it 'returns a collection of reason objects for the given state' do
        expect(reasons).to be_kind_of(Array)
        expect(reasons.size).to eq(1)
        expect(reasons.first.code).to eq(:test)
        expect(reasons.first.description).to eq('description')
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

    context 'for a Litigator interim, disbursement only claim' do
      let(:claim) { create(:interim_claim, :disbursement_only_fee, state: 'rejected') }

      it { expect(subject.count).to eq 9 }
    end

    context 'for an advocate claim' do
      let(:claim) { create(:advocate_claim, state: 'rejected') }

      it { expect(subject.count).to eq 7 }
    end
  end

  describe '.refuse_reasons_for' do
    subject(:refuse_reasons_for) { described_class.refuse_reasons_for(claim) }

    context 'for a Litigator claim' do
      let(:claim) { create(:transfer_claim, state: 'refused') }

      it { expect(subject.count).to eq 2 }
    end

    context 'for a Litigator interim claim' do
      let(:claim) { create(:interim_claim, state: 'refused') }

      it { expect(subject.count).to eq 5 }
    end

    context 'for an advocate claim' do
      let(:claim) { create(:advocate_claim, state: 'refused') }

      it { expect(subject.count).to eq 3 }
    end
  end

  describe '.get' do
    let(:code) { 'code' }
    let(:reason) { described_class.get(code) }

    context 'for an existing code' do
      before do
        allow(described_class).to receive(:description_for).with(code).and_return('description')
      end

      it 'initializes and retrieve a reason object if code exists' do
        expect(reason.code).to eq('code')
        expect(reason.description).to eq('description')
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
end
