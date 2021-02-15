require 'rails_helper'

class Caching
  describe MemoryStore do
    describe '.current' do
      context 'after a call has been made already' do
        it 'returns the previously instantiated object' do
          store = MemoryStore.current
          expect(MemoryStore.current).to eq store
        end
      end
    end

    describe '#get, #set' do
      it 'stores and sets the value' do
        MemoryStore.current.set('key1', 'value1')
        MemoryStore.current.set('key2', 'value2')
        expect(MemoryStore.current.get('key1')).to eq 'value1'
        expect(MemoryStore.current.get('key2')).to eq 'value2'
      end
    end

    describe '#clear' do
      it 'removes all previous values' do
        MemoryStore.current.set('key1', 'value1')
        MemoryStore.current.clear
        expect(MemoryStore.current.get('key1')).to be_nil
      end
    end
  end
end
