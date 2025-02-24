# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :decimal(, )
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
#  date                  :date
#

class Fee::BasicFee < Fee::BaseFee
  belongs_to :fee_type, class_name: 'Fee::BasicFeeType'

  attr_writer :toggle

  delegate :validation_order, to: :class

  validates_with Fee::BasicFeeValidator

  default_scope { order(claim_id: :asc, fee_type_id: :asc) }

  def is_basic?
    true
  end

  def self.validation_order
    :position
  end
end
