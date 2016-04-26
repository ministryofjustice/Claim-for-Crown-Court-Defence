# == Schema Information
#
# Table name: determinations
#
#  id            :integer          not null, primary key
#  claim_id      :integer
#  type          :string
#  fees          :decimal(, )      default(0.0)
#  expenses      :decimal(, )      default(0.0)
#  total         :decimal(, )
#  created_at    :datetime
#  updated_at    :datetime
#  vat_amount    :float            default(0.0)
#  disbursements :decimal(, )      default(0.0)
#

class Determination < ActiveRecord::Base
  include NumberCommaParser
  numeric_attributes :fees, :expenses, :disbursements

  belongs_to :claim, class_name: 'Claim::BaseClaim', foreign_key: 'claim_id'

  before_save :calculate_total, :calculate_vat

  validate :fees_valid
  validate :expenses_valid
  validate :disbursements_valid


  def calculate_total
    self.total = [self.fees, self.expenses, self.disbursements].sum
  end

  def calculate_vat
    self.vat_amount = VatRate.vat_amount(self.total, self.claim.vat_date).round(2) if self.claim.apply_vat?
  end

  def total_including_vat
    (self.total || 0 ) + (self.vat_amount || 0)
  end

  def blank?
    zero_or_nil?(self.fees) && zero_or_nil?(self.expenses) && zero_or_nil?(self.disbursements)
  end

  def present?
    !blank?
  end

  private

  def fees_valid
    errors[:base] << 'Assessed fees must be greater than or equal to zero' if negative_or_nil?(self.fees)
  end

  def expenses_valid
    errors[:base] << 'Assessed expenses must be greater than or equal to zero' if negative_or_nil?(self.expenses)
  end

  def disbursements_valid
    errors[:base] << 'Assessed disbursements must be greater than or equal to zero' if negative_or_nil?(self.disbursements)
  end

  def zero_or_nil?(value)
    value.nil? || value == 0
  end

  def negative_or_nil?(value)
    value.nil? || value < 0
  end

end
