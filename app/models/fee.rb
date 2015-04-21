class Fee < ActiveRecord::Base
  belongs_to :claim
  belongs_to :fee_type
  validates_presence_of :amount, :quantity, :rate

  after_save do
    claim.update_fees_total
    claim.update_total
  end

  after_destroy do
    claim.update_fees_total
    claim.update_total
  end
end
