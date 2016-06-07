# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :decimal(, )
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#  sub_type_id           :integer
#  case_numbers          :string
#

class Fee::BasicFee < Fee::BaseFee
  belongs_to :fee_type, class_name: Fee::BasicFeeType

  validates_with Fee::BasicFeeValidator

  default_scope { order(claim_id: :asc, fee_type_id: :asc) }

  def self.new_blank(claim, fee_type)
    self.new(claim: claim, fee_type: fee_type, quantity: 0, amount: 0)
  end

  def is_basic?
    true
  end
end
