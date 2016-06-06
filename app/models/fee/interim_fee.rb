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

class Fee::InterimFee < Fee::BaseFee
  include Fee::InterimFeeTypeCodes

  belongs_to :fee_type, class_name: Fee::InterimFeeType

  acts_as_gov_uk_date :warrant_issued_date, :warrant_executed_date, validate_if: :perform_validation?

  validates_with Fee::InterimFeeValidator

  def is_interim?
    true
  end

  def code
    fee_type.try(:code)
  end
end
