# == Schema Information
#
# Table name: fee_types
#
#  id          :integer          not null, primary key
#  description :string
#  code        :string
#  created_at  :datetime
#  updated_at  :datetime
#  max_amount  :decimal(, )
#  calculated  :boolean          default(TRUE)
#  type        :string
#  roles       :string
#  parent_id   :integer
#

class Fee::WarrantFeeType < Fee::BaseFeeType

  default_scope { order(description: :asc) }

  def self.instance
    Fee::WarrantFeeType.first
  end

  def fee_category_name
    'Warrant Fee'
  end

end
