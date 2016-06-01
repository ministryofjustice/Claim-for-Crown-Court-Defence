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

class Fee::GraduatedFee < Fee::BaseFee

  belongs_to :fee_type, class_name: Fee::GraduatedFeeType

  acts_as_gov_uk_date :date

  validates :warrant_issued_date, :warrant_executed_date, :sub_type_id, :case_numbers, absence: true
  validates_with Fee::GraduatedFeeValidator

  def is_graduated?
    true
  end

end
