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

class Fee::GraduatedFee < Fee::BaseFee

  belongs_to :fee_type, class_name: Fee::GraduatedFeeType

  validates_with Fee::GraduatedFeeValidator

  def is_graduated?
    true
  end

end
