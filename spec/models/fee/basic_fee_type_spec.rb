require 'rails_helper'

module Fee
  describe BasicFeeType do
    let(:fee_type)  { build :basic_fee_type }

    describe '#has_dates_attended?' do
      it 'returns true' do
        expect(fee_type.has_dates_attended?).to be true
      end
    end
  end
end