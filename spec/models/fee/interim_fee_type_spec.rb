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
  describe InterimFeeType do

    describe '.by_unique_code' do
      it 'returns the record with the matching unique code' do
        create :interim_fee_type, unique_code: 'IFT1'
        create :interim_fee_type, unique_code: 'IFT3'
        ift_2 = create :interim_fee_type, unique_code: 'IFT2'

        expect(InterimFeeType.by_unique_code('IFT2')).to eq ift_2
      end
    end
  end
end
