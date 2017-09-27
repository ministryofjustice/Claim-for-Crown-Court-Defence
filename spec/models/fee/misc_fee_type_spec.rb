# == Schema Information
#
# Table name: fee_types
#
#  id                  :integer          not null, primary key
#  description         :string
#  code                :string
#  created_at          :datetime
#  updated_at          :datetime
#  max_amount          :decimal(, )
#  calculated          :boolean          default(TRUE)
#  type                :string
#  roles               :string
#  parent_id           :integer
#  quantity_is_decimal :boolean          default(FALSE)
#  unique_code         :string
#

require 'rails_helper'

module Fee
  describe MiscFeeType do

    let(:fee_type)  { build :misc_fee_type }

    describe '#fee_category_name' do
      it 'returns the category name' do
          expect(fee_type.fee_category_name).to eq 'Miscellaneous Fees'
      end
    end

    describe 'default scope' do
      before do
        create(:misc_fee_type, description: 'Ppppp')
        create(:misc_fee_type, description: 'Xxxxx')
        create(:misc_fee_type, description: 'Sssss')
      end

      it 'orders by description ascending' do
        expect(Fee::MiscFeeType.all.map(&:description)).to eq ['Ppppp','Sssss','Xxxxx']
      end
    end

    describe '#case_uplift?' do
      it 'returns true when fee_type is Case Uplift' do
        fee_type.code = 'XUPL'
        expect(fee_type.case_uplift?).to be_truthy
      end

      it 'returns false when fee_type is not Case Uplift' do
        fee_type.code = 'XXX'
        expect(fee_type.case_uplift?).to be_falsey
      end
    end
  end
end
