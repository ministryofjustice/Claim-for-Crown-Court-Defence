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
#  total                :decimal(, )      default(0.0)
#  uuid                 :uuid
#

class Disbursement < ApplicationRecord
  include NumberCommaParser
  include Duplicable

  belongs_to :disbursement_type
  belongs_to :claim, class_name: 'Claim::BaseClaim'

  numeric_attributes :net_amount, :vat_amount, :total

  validates_with DisbursementValidator

  before_validation do
    self.total = (net_amount || 0) + (vat_amount || 0)
  end

  before_save do
    self.net_amount = 0.0 if net_amount.nil?
    self.vat_amount = 0.0 if vat_amount.nil?
    self.total = 0.0 if total.nil?
  end

  after_save do
    claim.update_disbursements_total
    claim.update_total
    claim.update_vat
  end

  after_destroy do
    claim.update_disbursements_total
    claim.update_total
    claim.update_vat
  end

  def perform_validation?
    claim&.perform_validation?
  end

  def disbursement_type_unique_code=(code)
    self.disbursement_type = DisbursementType.find_by!(unique_code: code)
  end

  def vat_absent?
    vat_amount.nil? || vat_amount.zero?
  end

  def vat_present?
    !vat_absent?
  end
end
