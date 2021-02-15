require 'rails_helper'

class Caching
  describe AbstractStore do
    describe '.current' do
      it 'raises' do
        expect {
          AbstractStore.current
        }.to raise_error RuntimeError, 'not implemented'
      end
    end
  end
end
