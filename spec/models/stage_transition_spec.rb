require 'rails_helper'

RSpec.describe StageTransition do
  let(:next_stage_name) { :next_stage }
  let(:stagable_object) { double(:stagable_object) }
  let(:options) {
    {
      to_stage: next_stage_name,
      object: stagable_object
    }
  }

  subject(:transition) { described_class.new(options) }

  describe '#to_stage' do
    specify { expect(transition.to_stage).to eq(:next_stage) }

    context 'when to_stage is a string' do
      let(:next_stage_name) { 'str_stage' }
      specify { expect(transition.to_stage).to eq(:str_stage) }
    end
  end

  describe '#valid_condition?' do
    context 'when it does not have a condition' do
      let(:options) {
        {
          to_stage: next_stage_name,
          object: stagable_object
        }
      }

      specify { expect(transition.valid_condition?).to be_truthy }
    end

    context 'when it does have a condition' do
      let(:condition) { ->(object) { object.condition_met? } }
      let(:options) {
        {
          to_stage: next_stage_name,
          condition: condition,
          object: stagable_object
        }
      }

      context 'but the condition is not met' do
        before do
          allow(stagable_object).to receive(:condition_met?).and_return(false)
        end

        specify {
          expect(stagable_object).to receive(:condition_met?)
          expect(transition.valid_condition?).to be_falsey
        }
      end

      context 'and the condition is met' do
        before do
          allow(stagable_object).to receive(:condition_met?).and_return(true)
        end

        specify {
          expect(stagable_object).to receive(:condition_met?)
          expect(transition.valid_condition?).to be_truthy
        }
      end
    end
  end
end
