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

  # So we expose a consistent interface shared with Claim
  alias_attribute :fees_total, :fees
  alias_attribute :expenses_total, :expenses
  alias_attribute :disbursements_total, :disbursements

  def calculate_total
    self.total = [fees || 0.0, expenses || 0.0, disbursements || 0.0].sum
  end

  def calculate_vat
    return unless claim.is_a? Claim::AdvocateClaim
    self.vat_amount = VatRate.vat_amount(total, claim.vat_date, calculate: claim.apply_vat?).round(2)
  end

  def total_including_vat
    (total || 0) + (vat_amount || 0)
  end

  def blank?
    zero_or_nil?(fees) && zero_or_nil?(expenses) && zero_or_nil?(disbursements)
  end

  def zero?
    blank?
  end

  def present?
    !blank?
  end

  def to_s
    "  id:            #{id}\n" \
      "  type           #{type}\n" \
      "  claim_id:      #{claim_id}\n" \
      "  expenses:      #{expenses}\n" \
      "  fees:          #{fees}\n" \
      "  disbursements: #{disbursements}\n" \
      "  vat_amount:    #{vat_amount}\n" \
      "  total:         #{total}\n\n"
  end

  private

  def fees_valid
    errors[:base] << 'Assessed fees must be greater than or equal to zero' if negative_or_nil?(fees)
  end

  def expenses_valid
    errors[:base] << 'Assessed expenses must be greater than or equal to zero' if negative_or_nil?(expenses)
  end

  def disbursements_valid
    errors[:base] << 'Assessed disbursements must be greater than or equal to zero' if negative_or_nil?(disbursements)
  end

  def zero_or_nil?(value)
    value.nil? || value.zero?
  end

  def negative_or_nil?(value)
    value.nil? || value.negative?
  end
end
