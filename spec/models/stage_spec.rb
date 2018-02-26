require 'rails_helper'

RSpec.describe Stage do
  let(:stage_name) { :some_stage }
  let(:stagable_object) { double(:stagable_object) }
  let(:options) {
    {
      name: stage_name,
      object: stagable_object
    }
  }

  subject(:stage) { described_class.new(options) }

  describe '#name' do
    specify { expect(stage.name).to eq(stage_name) }
  end

  describe '#transitions' do
    context 'when no transitions are defined' do
      specify { expect(stage.transitions).to be_empty }
    end

    context 'when an empty set of transactions are supplied' do
      let(:transitions) { [] }
      let(:options) {
        {
          name: stage_name,
          transitions: transitions,
          object: stagable_object
        }
      }

      specify { expect(stage.transitions).to be_empty }
    end

    context 'when a set of transactions are supplied' do
      let(:transitions) {
        [
          {
            to_stage: :stage_1a,
            condition: ->(object) { object.stage_1a_condition? }
          },
          {
            to_stage: :stage_1b,
            condition: ->(object) { object.stage_1b_condition? }
          },
          { to_stage: :stage_1c }
        ]
      }
      let(:options) {
        {
          name: stage_name,
          transitions: transitions,
          object: stagable_object
        }
      }

      it 'returns a list of stage transitions' do
        expect(stage.transitions).to be_kind_of(Array)
        expect(stage.transitions.size).to eq(transitions.size)
        expect(stage.transitions).to all(be_kind_of(StageTransition))
      end
    end
  end

  describe '#first_valid_transition' do
    context 'when there is no transitions' do
      let(:options) {
        {
          name: stage_name,
          object: stagable_object
        }
      }

      specify { expect(stage.first_valid_transition).to be_nil }
    end

    context 'when there are transitions' do
      let(:options) {
        {
          name: stage_name,
          transitions: transitions,
          object: stagable_object
        }
      }

      context 'but there are no conditions' do
        let(:transitions) {
          [
            { to_stage: :stage_1a },
            { to_stage: :stage_1b },
            { to_stage: :stage_1c }
          ]
        }

        it 'returns the stage defined in the first transition' do
          expect(stage.first_valid_transition).to eq(:stage_1a)
        end
      end

      context 'and the transitions have conditions to be met' do
        let(:transitions) {
          [
            {
              to_stage: :stage_1a,
              condition: ->(object) { object.stage_1a_condition? }
            },
            {
              to_stage: :stage_1b,
              condition: ->(object) { object.stage_1b_condition? }
            },
            { to_stage: :stage_1c }
          ]
        }

        it 'returns the first stage for which its condition is met' do
          allow(stagable_object).to receive(:stage_1a_condition?).and_return(false)
          allow(stagable_object).to receive(:stage_1b_condition?).and_return(true)
          expect(stage.first_valid_transition).to eq(:stage_1b)

          allow(stagable_object).to receive(:stage_1a_condition?).and_return(false)
          allow(stagable_object).to receive(:stage_1b_condition?).and_return(false)
          expect(stage.first_valid_transition).to eq(:stage_1c)

          allow(stagable_object).to receive(:stage_1a_condition?).and_return(true)
          allow(stagable_object).to receive(:stage_1b_condition?).and_return(true)
          expect(stage.first_valid_transition).to eq(:stage_1a)
        end
      end
    end
  end

  describe '#to_sym' do
    let(:stage_name) { :sym_stage }
    specify { expect(stage.to_sym).to eq(:sym_stage) }

    context 'when stage name is a string' do
      let(:stage_name) { 'str_stage' }
      specify { expect(stage.to_sym).to eq(:str_stage) }
    end
  end

  describe '#<=>' do
    context 'when other stage is nil' do
      specify { expect(stage == nil).to be_falsey }
    end

    context 'when other stage is a string' do
      context 'and the other stage name is not the same' do
        specify { expect(stage == 'different_stage').to be_falsey }
      end

      context 'and the other stage name is the same' do
        specify { expect(stage == 'some_stage').to be_truthy }
      end
    end

    context 'when other stage is a symbol' do
      context 'and the other stage name is not the same' do
        specify { expect(stage == :different_stage).to be_falsey }
      end

      context 'and the other stage name is the same' do
        specify { expect(stage == :some_stage).to be_truthy }
      end
    end

    context 'when other stage is a Stage object' do
      let(:other_stage) {
        described_class.new(
          name: other_stage_name,
          object: stagable_object
        )
      }

      context 'and the other stage name is not the same' do
        let(:other_stage_name) { :different_stage }
        specify { expect(stage == other_stage).to be_falsey }
      end

      context 'and the other stage name is the same' do
        let(:other_stage_name) { :some_stage }
        specify { expect(stage == other_stage).to be_truthy }
      end
    end
  end
end
