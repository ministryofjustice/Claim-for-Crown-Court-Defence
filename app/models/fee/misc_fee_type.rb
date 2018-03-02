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

class Fee::MiscFeeType < Fee::BaseFeeType
  EpfAmount = Struct.new(:description, :amount)

  EPF_AMOUNTS =
  {
    1 => EpfAmount.new('£45', 45.00),
    2 => EpfAmount.new('£90', 90.00),
  }.freeze

  default_scope { order(description: :asc) }

  def fee_category_name
    'Miscellaneous Fees'
  end
end
