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
#  parent_id   :integer
#

class Fee::TransferFeeType < Fee::BaseFeeType

  def self.instance
    Fee::TransferFeeType.first
  end

  def fee_category_name
    'Transfer Fee'
  end

end
