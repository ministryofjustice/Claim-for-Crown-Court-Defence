# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string
#  code            :string
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  max_amount      :decimal(, )
#

class FeeType < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  BASIC_FEE_CODES = %w( BAF DAF DAH DAJ PCM SAF )

  belongs_to :fee_category

  has_many :fees, dependent: :destroy
  has_many :claims, through: :fees

  validates :fee_category, presence: {message: 'Fee category cannot be blank' }
  validates :description, presence: {message: 'Fee type description cannot be blank'}, uniqueness: { case_sensitive: false, scope: :fee_category, message: 'Fee type description must be unique' }
  validates :code, presence: {message: 'Fee type code cannot be blank'}

  def self.basic
    self.by_fee_category("BASIC").unscope(:order).order(id: :asc)
  end

  def self.fixed
    self.by_fee_category("FIXED")
  end

  def self.misc
    self.by_fee_category("MISC")
  end

  def has_dates_attended?
    BASIC_FEE_CODES.include?(self.code)
  end


  def pretty_max_amount
    number_to_currency(self.max_amount, precision: 0)
  end

private

  def self.by_fee_category(category)
    self.joins(:fee_category).where('fee_categories.abbreviation = ?', category.upcase).order(:description)
  end

end
