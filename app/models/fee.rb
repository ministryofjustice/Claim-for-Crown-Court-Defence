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

  def self.new_blank(claim, fee_type)
    Fee.new(claim: claim, fee_type: fee_type, quantity: 0, rate: 0, amount: 0)
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
            rate: params['rate'],
            amount: params['amount'])
  end

  def blank?
    self.quantity == 0 && self.rate == 0 && self.amount == 0
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

end
