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
#

class Fee < ActiveRecord::Base
  include NumberCommaParser
  numeric_attributes :quantity, :amount

  belongs_to :claim
  belongs_to :fee_type

  has_many :dates_attended, as: :attended_item, dependent: :destroy

  default_scope { includes(:fee_type) }

  validates :fee_type, presence: { message: 'Fee type cannot be blank' }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :basic_fee_quantity

  accepts_nested_attributes_for :dates_attended, reject_if: :all_blank, allow_destroy: true

  before_validation do
    self.quantity = 0 if self.quantity.blank?
    self.amount = 0 if self.amount.blank?
  end

  after_save do
    claim.update_fees_total
    claim.update_total
  end

  after_destroy do
    claim.update_fees_total
    claim.update_total
  end

  def self.new_blank(claim, fee_type)
    Fee.new(claim: claim, fee_type: fee_type, quantity: 0, amount: 0)
  end

  def self.new_collection_from_form_params(claim, form_params)
    collection = []
    form_params.values.each { |params| collection << Fee.new_from_form_params(claim, params) }
    collection
  end

  def self.new_from_form_params(claim, params)
    Fee.new(claim: claim,
            fee_type: FeeType.find(params['fee_type_id']),
            quantity: params['quantity'],
            amount: params['amount']
            )
  end

  def blank?
    self.quantity == 0 && self.amount == 0
  end

  def present?
    !blank?
  end

  def is_basic?
    fee_type.fee_category.is_basic?
  end

  def description
    fee_type.description
  end

  def category
    fee_type.fee_category.abbreviation
  end

  def clear
    self.quantity = nil;
    self.amount = nil;
  end

  private

  def basic_fee_quantity
    if fee_type.present? && more_than_one_basic_fee? # fee_spec.rb:22/24/26 fail unless this fee_type.present? is used here
      errors[:quantity] << '- only one basic fee can be claimed per case'
    end
  end

  def more_than_one_basic_fee?
    fee_type.description == 'Basic Fee' && quantity > 1
  end

end
