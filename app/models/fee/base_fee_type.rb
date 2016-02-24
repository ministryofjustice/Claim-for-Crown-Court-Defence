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
#  calculated      :boolean          default(TRUE)
#  type            :string
#

class Fee::BaseFeeType < ActiveRecord::Base

  self.table_name = 'fee_types'

  auto_strip_attributes :code, :description, squish: true, nullify: true

  include ActionView::Helpers::NumberHelper

  has_many :fees, dependent: :destroy, class_name: Fee::BaseFee, foreign_key: :fee_type_id
  has_many :claims, through: :fees

  validates :description, presence: {message: 'Fee type description cannot be blank'}, uniqueness: { case_sensitive: false, scope: :type, message: 'Fee type description must be unique' }
  validates :code, presence: {message: 'Fee type code cannot be blank'}

  def has_dates_attended?
    false
  end

  def pretty_max_amount
    number_to_currency(self.max_amount, precision: 0)
  end

  def fee_class_name
    self.type.sub(/Type$/, '')
  end

  #utility methods for providing access to subclasses

  def self.basic
    Fee::BasicFeeType.all
  end

  def self.misc
    Fee::MiscFeeType.all
  end

  def self.fixed
    Fee::FixedFeeType.all
  end
  
private

  def self.by_fee_category(category)
    self.joins(:fee_category).where('fee_categories.abbreviation = ?', category.upcase).order(:description)
  end

end
