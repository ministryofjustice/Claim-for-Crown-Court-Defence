# == Schema Information
#
# Table name: fee_types
#
#  id          :integer          not null, primary key
#  description :string
#  code        :string
#  created_at  :datetime
#  updated_at  :datetime
#  max_amount  :decimal(, )
#  calculated  :boolean          default(TRUE)
#  type        :string
#  roles       :string
#

require 'rails_helper'

module Fee
  describe FixedFeeType do

    let(:fee_type)  { build :fixed_fee_type }

    describe '#fee_category_name' do
      it 'should return the category name' do
          expect(fee_type.fee_category_name).to eq 'Fixed Fees'
      end
    end

    describe 'default scope' do
      before do
        create(:fixed_fee_type, description: 'Ppppp')
        create(:fixed_fee_type, description: 'Xxxxx')
        create(:fixed_fee_type, description: 'Sssss')
      end

      it 'should order by description ascending' do
        expect(Fee::FixedFeeType.all.map(&:description)).to eq ['Ppppp','Sssss','Xxxxx']
      end
    end

  end
end
