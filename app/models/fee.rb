# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  rate        :decimal(, )
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#

class Fee < ActiveRecord::Base
  belongs_to :claim
  belongs_to :fee_type
  has_many :dates_attended, dependent: :destroy, inverse_of: :fee

  default_scope { includes(:fee_type) }

  validates :fee_type, presence: true
  validates :quantity, :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :dates_attended, reject_if: :all_blank,  allow_destroy: true

  before_validation do
    self.amount = ((self.rate || 0) * (self.quantity || 0)).abs
  end

  after_save do
    claim.update_fees_total
    claim.update_total
  end

  after_destroy do
    claim.update_fees_total
    claim.update_total
  end
end
