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
  describe HardshipFeeType do
    subject(:hardship_fee_type) { described_class.new }

    describe '.fee_category_name' do
      subject(:fee_category_name) { hardship_fee_type.fee_category_name }

      it { is_expected.to eq 'Hardship Fee' }
    end
  end
end
