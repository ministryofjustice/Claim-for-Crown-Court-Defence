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

class Fee::InterimFeeType < Fee::BaseFeeType
  include Fee::InterimFeeTypeCodes

  default_scope -> { order(parent_id: :desc, description: :asc) }

  # FIXME: all interim fee types have nil parent_ids - remove if not needed
  # scope :top_levels, -> { where(parent_id: nil) }
  scope :for_trials, -> { where.not(unique_code: RETRIAL_APPLICABLE) }
  scope :for_retrials, -> { where.not(unique_code: TRIAL_APPLICABLE) }

  def fee_category_name
    'Interim Fees'
  end

  def self.by_unique_code(code)
    where(unique_code: code).first
  end
end
