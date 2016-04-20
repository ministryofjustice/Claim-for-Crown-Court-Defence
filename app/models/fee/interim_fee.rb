# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :integer
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#  sub_type_id           :integer
#  case_numbers          :string
#  disbursement_type_id  :integer
#

class Fee::InterimFee < Fee::BaseFee

  belongs_to :fee_type, class_name: Fee::InterimFeeType
  belongs_to :disbursement_type

  validates_with Fee::InterimFeeValidator

  def is_interim?
    true
  end

  def is_effective_pcmh?
    fee_type_code? 'IPCMH'
  end

  def is_retrial_new_solicitor?
    fee_type_code? 'IRNS'
  end

  def is_retrial_start?
    fee_type_code? 'IRST'
  end

  def is_trial_start?
    fee_type_code? 'ITST'
  end

  def is_disbursement?
    fee_type_code? 'IDISO'
  end

  def is_warrant?
    fee_type_code? 'IWARR'
  end

  private

  def fee_type_code?(code)
    self.fee_type && self.fee_type.code == code
  end

end
