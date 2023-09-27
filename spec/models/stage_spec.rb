require 'rails_helper'

RSpec.describe Stage do
  subject(:stage) { described_class.new(**options) }

  let(:stage_name) { :some_stage }
  let(:stagable_object) { double(:stagable_object) }
  let(:options) do
    {
      name: stage_name,
      object: stagable_object
    }
  end

  describe '#name' do
    it { expect(stage.name).to eq(stage_name) }
  end

  describe '#transitions' do
    context 'when no transitions are defined' do
      it { expect(stage.transitions).to be_empty }
    end

    context 'when an empty set of transitions are supplied' do
      let(:transitions) { [] }
      let(:options) do
        {
          name: stage_name,
          transitions:,
          object: stagable_object
        }
      end

      it { expect(stage.transitions).to be_empty }
    end

    context 'when a set of transitions are supplied' do
      let(:transitions) do
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
      end
      let(:options) do
        {
          name: stage_name,
          transitions:,
          object: stagable_object
        }
      end

      it { expect(stage.transitions).to be_a(Array) }
      it { expect(stage.transitions.size).to eq(transitions.size) }
      it { expect(stage.transitions).to all(be_a(StageTransition)) }
    end
  end

  describe '#first_valid_transition' do
    context 'when there are no transitions' do
      it { expect(stage.first_valid_transition).to be_nil }
    end

    context 'when there are transitions with no conditions' do
      let(:options) do
        {
          name: stage_name,
          transitions:,
          object: stagable_object
        }
      end

      let(:transitions) do
        [
          { to_stage: :stage_1a },
          { to_stage: :stage_1b },
          { to_stage: :stage_1c }
        ]
      end

      it 'returns the stage defined in the first transition' do
        expect(stage.first_valid_transition).to eq(:stage_1a)
      end
    end

    context 'when the transitions have conditions to be met' do
      let(:options) do
        {
          name: stage_name,
          transitions:,
          object: stagable_object
        }
      end

      let(:transitions) do
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
      end

      context 'when the conditions for stage_1b are met' do
        before do
          allow(stagable_object).to receive_messages(stage_1a_condition?: false, stage_1b_condition?: true)
        end

        it { expect(stage.first_valid_transition).to eq(:stage_1b) }
      end

      context 'when the conditions for stage_1c are met' do
        before do
          allow(stagable_object).to receive_messages(stage_1a_condition?: false, stage_1b_condition?: false)
        end

        it { expect(stage.first_valid_transition).to eq(:stage_1c) }
      end

      context 'when the conditions for stage_1a are met' do
        before do
          allow(stagable_object).to receive_messages(stage_1a_condition?: true, stage_1b_condition?: true)
        end

        it { expect(stage.first_valid_transition).to eq(:stage_1a) }
      end
    end
  end

  describe '#to_sym' do
    let(:stage_name) { :sym_stage }

    it { expect(stage.to_sym).to eq(:sym_stage) }

    context 'when stage name is a string' do
      let(:stage_name) { 'str_stage' }

      it { expect(stage.to_sym).to eq(:str_stage) }
    end
  end

  describe '#<=>' do
    context 'when other stage is nil' do
      it { expect(stage).not_to be_nil }
    end

    context 'when other stage is a string' do
      context 'when the other stage name is not the same' do
        it { expect(stage == 'different_stage').to be_falsey }
      end

      context 'when the other stage name is the same' do
        it { expect(stage == 'some_stage').to be_truthy }
      end
    end

    context 'when other stage is a symbol' do
      context 'when the other stage name is not the same' do
        it { expect(stage == :different_stage).to be_falsey }
      end

      context 'when the other stage name is the same' do
        it { expect(stage == :some_stage).to be_truthy }
      end
    end

    context 'when other stage is a Stage object' do
      let(:other_stage) do
        described_class.new(
          name: other_stage_name,
          object: stagable_object
        )
      end

      context 'when the other stage name is not the same' do
        let(:other_stage_name) { :different_stage }

        it { expect(stage == other_stage).to be_falsey }
      end

      context 'when the other stage name is the same' do
        let(:other_stage_name) { :some_stage }

        it { expect(stage == other_stage).to be_truthy }
      end
    end
  end
end
