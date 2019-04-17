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
  AGFS_SUPPLEMENTARY_ONLY_TYPES = %w[MISAF MIPCM].freeze
  AGFS_SUPPLEMENTARY_SHARED_TYPES = %w[MISPF MIWPF MIDTH MIDTW MIDHU MIDWU MIDSE MIDSU].freeze
  AGFS_SUPPLEMENTARY_TYPES = (AGFS_SUPPLEMENTARY_ONLY_TYPES + AGFS_SUPPLEMENTARY_SHARED_TYPES).freeze

  default_scope { order(description: :asc) }

  scope :without_supplementary_only, -> { where.not(unique_code: AGFS_SUPPLEMENTARY_ONLY_TYPES) }
  scope :supplementary, -> { where(unique_code: AGFS_SUPPLEMENTARY_TYPES) }

  def fee_category_name
    'Miscellaneous Fees'
  end
end
