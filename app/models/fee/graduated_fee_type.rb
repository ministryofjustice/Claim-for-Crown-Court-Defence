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

class Fee::GraduatedFeeType < Fee::BaseFeeType
  default_scope { order(description: :asc) }

  def fee_category_name
    'Graduated Fees'
  end

  def self.by_unique_code(code)
    find_by(unique_code: code)
  end
end
