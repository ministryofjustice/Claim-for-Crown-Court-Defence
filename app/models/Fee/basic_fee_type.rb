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

  def has_dates_attended?
    true
  end

   def fee_category_name
    'Basic Fees'
  end

end
