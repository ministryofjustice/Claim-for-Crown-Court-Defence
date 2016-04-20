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

class Fee::InterimFeeType < Fee::BaseFeeType

  default_scope -> { order(parent_id: :desc, description: :asc) }

  scope :top_levels,              -> { where(parent_id: nil) }

  def fee_category_name
    'Interim Fees'
  end

  def self.by_code(code)
    self.where(code: code).first
  end

  def is_effective_pcmh?
    code == 'IPCMH'
  end

  def is_retrial_new_solicitor?
    code == 'IRNS'
  end

  def is_retrial_start?
    code == 'IRST'
  end

  def is_trial_start?
    code == 'ITST'
  end

  def is_disbursement?
    code == 'IDISO'
  end

  def is_warrant?
    code == 'IWARR'
  end







end
