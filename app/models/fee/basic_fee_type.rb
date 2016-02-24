# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string
#  code            :string
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  max_amount      :decimal(, )
#  calculated      :boolean          default(TRUE)
#  type            :string
#

class Fee::BasicFeeType < Fee::BaseFeeType

  CODES_REQUIRING_DATES_ATTENDED = %w( BAF DAF DAH DAJ PCM SAF )

  def has_dates_attended?
    CODES_REQUIRING_DATES_ATTENDED.include?(self.code)
  end

   def fee_category_name
    'Basic Fees'
  end

end
