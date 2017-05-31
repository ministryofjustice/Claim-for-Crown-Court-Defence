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

class Fee::TransferFee < Fee::BaseFee
  belongs_to :fee_type, class_name: Fee::TransferFeeType

  validates :warrant_issued_date, :warrant_executed_date, :sub_type_id, :case_numbers, absence: true
  validates_with Fee::TransferFeeValidator

  after_initialize :assign_fee_type

  def is_transfer?
    true
  end

  def self.instance
    Fee::TransferFee.first
  end

  private

  def assign_fee_type
    self.fee_type = Fee::TransferFeeType.instance
  end
end
