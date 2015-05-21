class Fee < ActiveRecord::Base
  belongs_to :claim
  belongs_to :fee_type

  default_scope { includes(:fee_type) }

  validates :fee_type, presence: true
  validates :amount, :quantity, :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_save do
    claim.update_fees_total
    claim.update_total
  end

  after_destroy do
    claim.update_fees_total
    claim.update_total
  end
end
