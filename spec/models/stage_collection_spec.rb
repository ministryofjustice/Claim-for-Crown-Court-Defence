require 'rails_helper'

RSpec.describe StageCollection do
  let(:stages) {
    [
      {
        name: :stage_1,
        transitions: [{ to_stage: :stage_2 }]
      },
      { name: :stage_2 }
    ]
  }
  let(:stagable_object) { double(:stagable_object) }

  subject(:collection) { described_class.new(stages, stagable_object) }

  describe '#stages' do
    it 'should be an array of Stages' do
      expect(collection.stages).to be_kind_of(Array)
      expect(collection.stages.size).to eq(stages.size)
      expect(collection.stages).to all(be_a(Stage))
    end
  end

  context 'when enumerating' do
    describe '#each' do
      it { expect { |b| collection.each(&b) }.to yield_successive_args(kind_of(Stage), kind_of(Stage)) }
    end

    describe '#map' do
      it { expect(collection.map(&:name)).to eql(%i[stage_1 stage_2]) }
    end

    describe '#first' do
      it 'returns the first defined stage' do
        expect(collection.first).to eq(collection.stages.first)
      end
    end
  end

  describe '#size' do
    it 'returns the total amount of stages' do
      expect(collection.size).to eq(stages.size)
    end
  end

  describe '#second' do
    it 'returns the second defined stage' do
      expect(collection.second).to eq(collection.stages.second)
    end
  end

  describe '#last' do
    it 'returns the last defined stage' do
      expect(collection.last).to eq(collection.stages.last)
    end
  end

  describe '#next_stage' do
    context 'when the given stage is not defined' do
      let(:given_stage) { :non_existent_stage }
      specify { expect(collection.next_stage(given_stage)).to be_nil }
    end

    context 'when the given stage is defined' do
      let(:stages) {
        [
          {
            name: :stage_1,
            transitions: [{ to_stage: :stage_2 }]
          },
          { name: :stage_2 }
        ]
      }

      context 'and there is a valid transition' do
        let(:given_stage) { :stage_1 }

        it 'returns the next stage relative to a given stage' do
          expect(collection.next_stage(given_stage)).to eq(:stage_2)
        end
      end

      context 'and there is no valid transition' do
        let(:given_stage) { :stage_2 }
        specify { expect(collection.next_stage(given_stage)).to be_nil }
      end
    end
  end

  describe '#path_until' do
    context 'when the given stage is nil' do
      specify { expect(collection.path_until(nil)).to be_empty }
    end

    context 'when the given stage is not part of the collection' do
      specify { expect(collection.path_until(:non_existent_stage)).to be_empty }
    end

    context 'when the given stage is part of the collection' do
      it 'returns the set of stages to the given stage' do
        expect(collection.path_until(:stage_1).map(&:to_sym))
          .to match_array(%i[stage_1])
        expect(collection.path_until(:stage_2).map(&:to_sym))
          .to match_array(%i[stage_1 stage_2])
      end

      context 'but its only reachable if some condition is met' do
        let(:stages) {
          [
            {
              name: :stage_1,
              transitions: [
                {
                  to_stage: :stage_2,
                  condition: ->(object) { object.some_condition? }
                }
              ]
            },
            { name: :stage_2 }
          ]
        }

        context 'and the condition is not met' do
          before do
            allow(stagable_object).to receive(:some_condition?).and_return(false)
          end

          specify { expect(collection.path_until(:stage_2)).to be_empty }
        end

        context 'and the condition is met' do
          before do
            allow(stagable_object).to receive(:some_condition?).and_return(true)
          end

          it 'returns the set of stages to the given stage' do
            expect(collection.path_until(:stage_2).map(&:to_sym))
              .to match_array(%i[stage_1 stage_2])
          end
        end
      end
    end
  end
end
