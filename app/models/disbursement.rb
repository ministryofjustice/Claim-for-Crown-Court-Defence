# == Schema Information
#
# Table name: disbursements
#
#  id                   :integer          not null, primary key
#  disbursement_type_id :integer
#  claim_id             :integer
#  net_amount           :decimal(, )
#  vat_amount           :decimal(, )
#  created_at           :datetime
#  updated_at           :datetime
#

class Disbursement < ActiveRecord::Base
  include NumberCommaParser
  include Duplicable

  belongs_to :disbursement_type
  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  numeric_attributes :net_amount, :vat_amount, :total

  validates_with DisbursementValidator

  before_validation do
    self.total = (self.net_amount || 0) + (self.vat_amount || 0)
  end

  after_save do
    claim.update_disbursements_total
    claim.update_total
  end

  after_destroy do
    claim.update_disbursements_total
    claim.update_total
    claim.update_vat
  end

  def perform_validation?
    claim && claim.perform_validation?
  end
end
