# frozen_string_literal: true

RSpec.shared_examples 'a claim journeys query' do
  describe '#prepare' do
    subject(:prepare) { instance.prepare }

    context 'when journeys function does not exist' do
      before do
        ActiveRecord::Base.connection.execute(instance.send(:drop_journeys_func))
      end

      specify 'function does not exist prior to call' do
        expect(instance.send(:journeys_func_exists?)).to be false
      end

      it 'creates the journeys function' do
        prepare
        expect(instance.send(:journeys_func_exists?)).to be true
      end
    end

    context 'when journeys function already exists' do
      before do
        allow(Settings).to receive(:replace_journeys_func?).and_return(replace_flag)
        ActiveRecord::Base.connection.execute(instance.send(:create_journeys_func))
        allow(instance).to receive(:recreate_journeys_func)
      end

      let(:replace_flag) { false }

      specify 'function exists prior to call' do
        expect(instance.send(:journeys_func_exists?)).to be true
      end

      context 'with replace flag false' do
        let(:replace_flag) { false }

        it 'does not recreate function' do
          prepare
          expect(instance).not_to have_received(:recreate_journeys_func)
        end
      end

      context 'with replace flag true' do
        let(:replace_flag) { true }

        it 'recreates function' do
          prepare
          expect(instance).to have_received(:recreate_journeys_func).once
        end
      end
    end
  end

  describe '#journeys_query' do
    subject(:journeys_query) { instance.journeys_query }

    it { is_expected.to be_instance_of(String) }
  end
end
