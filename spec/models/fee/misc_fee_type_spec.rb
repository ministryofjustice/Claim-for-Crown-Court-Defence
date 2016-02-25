require 'rails_helper'

module Fee
  describe MiscFeeType do

    let(:fee_type)  { build :misc_fee_type }

    describe '#fee_category_name' do
      it 'should return the category name' do
          expect(fee_type.fee_category_name).to eq 'Miscellaneous Fees'
      end
    end

    describe 'default scope' do
      before do
        create(:misc_fee_type, description: 'Ppppp')
        create(:misc_fee_type, description: 'Xxxxx')
        create(:misc_fee_type, description: 'Sssss')
      end

      it 'should order by description ascending' do
        expect(Fee::MiscFeeType.all.map(&:description)).to eq ['Ppppp','Sssss','Xxxxx']
      end
    end

  end
end
