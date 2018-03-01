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

  def perform_validation?
    (claim&.perform_validation? && validation_required?) || claim&.from_json_import?
  end

  def validation_required?
    # TODO: all these validations processes should be much simpler
    # than they are now.
    # - The validations for the API should be isolated instead of having
    # ternaries all around the code to deal with it :S
    return true if claim&.from_api?
    claim&.step_in_steps_range?(:fees)
  end
end
