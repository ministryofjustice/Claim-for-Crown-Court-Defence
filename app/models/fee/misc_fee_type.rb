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

class Fee::MiscFeeType < Fee::BaseFeeType

  default_scope { order(description: :asc) }

  def fee_category_name
    'Miscellaneous Fees'
  end

end
