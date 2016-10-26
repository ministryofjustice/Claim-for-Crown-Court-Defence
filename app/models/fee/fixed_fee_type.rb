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

class Fee::FixedFeeType < Fee::BaseFeeType
  has_many :children, class_name: Fee::FixedFeeType, foreign_key: :parent_id
  belongs_to :parent, class_name: Fee::FixedFeeType, foreign_key: :parent_id

  default_scope -> { order(parent_id: :desc, description: :asc) }

  scope :top_levels,              -> { where(parent_id: nil) }

  def fee_category_name
    'Fixed Fees'
  end

  def self.by_code(code)
    self.where(code: code).first
  end
end
