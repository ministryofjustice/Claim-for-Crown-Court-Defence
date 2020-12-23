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

class Fee::HardshipFee < Fee::BaseFee
  belongs_to :fee_type, class_name: 'Fee::HardshipFeeType'

  validates_with Fee::HardshipFeeValidator

  after_initialize :default_values

  def is_hardship?
    true
  end

  private

  def default_values
    self.fee_type ||= Fee::HardshipFeeType.find_by(unique_code: 'HARDSHIP')
  end
end
