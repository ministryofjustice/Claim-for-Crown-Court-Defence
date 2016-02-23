# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#  uuid        :uuid
#  rate        :decimal(, )
#  type        :string
#

class Fee::FixedFee < Fee::BaseFee

  belongs_to :fee_type, class_name: Fee::FixedFeeType

  validates_with Fee::FixedFeeValidator

  def is_fixed?
    true
  end
  
end
