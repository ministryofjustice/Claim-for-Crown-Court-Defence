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

class Fee::GraduatedFeeType < Fee::BaseFeeType

  default_scope { order(description: :asc) }

  def fee_category_name
    'Graduated Fees'
  end

  def self.by_code(code)
    self.where(code: code).first
  end
end
