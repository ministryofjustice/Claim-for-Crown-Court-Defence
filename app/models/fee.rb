# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#  uuid        :uuid
#  rate        :decimal(, )
#

class Fee < ActiveRecord::Base
  include NumberCommaParser
  numeric_attributes :quantity, :amount

  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id
  belongs_to :fee_type

  has_many :dates_attended, as: :attended_item, dependent: :destroy, inverse_of: :attended_item

  default_scope { includes(:fee_type) }

  validates_with FeeValidator
  validates_with FeeSubModelValidator

  accepts_nested_attributes_for :dates_attended, reject_if: :all_blank, allow_destroy: true

  before_validation do
    self.quantity   = 0 if self.quantity.blank?
    self.rate       = 0 if self.rate.blank?
    self.amount     = 0 if self.amount.blank?
    calculate_amount
  end

  after_save do
    claim.update_fees_total
    claim.update_total
  end

  after_destroy do
    claim.update_fees_total
    claim.update_total
    claim.update_vat
  end

  def self.new_blank(claim, fee_type)
    Fee.new(claim: claim, fee_type: fee_type, quantity: 0, amount: 0)
  end

  def perform_validation?
    claim && claim.perform_validation?
  end

  # TODO: this should be removed once those claims (on gamma/beta-testing) created prior to rate being reintroduced
  #       have been deleted/archived.
  def is_before_rate_reintroduced?
    self.amount > 0 && self.rate == 0
  end

  def calculated?
    fee_type.calculated? rescue true
  end

  def calculate_amount
    return if is_before_rate_reintroduced? || !calculated?
    self.amount = self.quantity * self.rate
  end

  def blank?
    self.quantity == 0 && self.amount == 0
  end

  def present?
    !blank?
  end

  def description
    fee_type.description
  end

  def category
    fee_type.fee_category.abbreviation
  end

  def clear
    self.quantity = nil;
    self.rate = nil;
    self.amount = nil;
    # explicitly destroy child relations
    self.dates_attended.destroy_all unless self.dates_attended.empty?
  end

  def method_missing(method, *args)
    if [:is_misc?,:is_basic?,:is_fixed?].include?(method)
      fee_type.fee_category.__send__(method) unless fee_type.nil?
    else
      super
    end
  end

end
