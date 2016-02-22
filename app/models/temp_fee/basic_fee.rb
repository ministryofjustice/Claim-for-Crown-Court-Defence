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

class Fee::BasicFee < Fee::BaseFee

  belongs_to :fee_type, class_name: Fee::BasicFeeType

  validates_with Fee::BasicFeeValidator
  

  def self.new_blank(claim, fee_type)
    self.new(claim: claim, fee_type: fee_type, quantity: 0, amount: 0)
  end

  def is_basic?
    true
  end


end
