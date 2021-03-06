# == Schema Information
#
# Table name: fee_types
#
#  id                  :integer          not null, primary key
#  description         :string
#  code                :string
#  created_at          :datetime
#  updated_at          :datetime
#  max_amount          :decimal(, )
#  calculated          :boolean          default(TRUE)
#  type                :string
#  roles               :string
#  parent_id           :integer
#  quantity_is_decimal :boolean          default(FALSE)
#  unique_code         :string
#

class Fee::BasicFeeType < Fee::BaseFeeType
  DATES_ATTENDED_APPLICABLE_FEES = %w[BAF DAF DAH DAJ PCM SAF DAT].freeze
  ADDITIONAL_DAILY_ATTENDANCE_FEE_CODES = %w[DAF DAH DAJ DAT].freeze

  default_scope { order(id: :asc) }

  def requires_dates_attended?
    DATES_ATTENDED_APPLICABLE_FEES.include?(code)
  end

  def fee_category_name
    'Basic Fees'
  end
end
