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
#  date                  :date
#
class Fee::MiscFee < Fee::BaseFee
  belongs_to :fee_type, class_name: 'Fee::MiscFeeType'

  validates_with Fee::MiscFeeValidator

  before_validation :miumu_quantity

  def is_misc?
    true
  end

  private

  def miumu_quantity
    self.quantity = 1.to_f if fee_type_id == 108 && rate
  end
end
