# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string(255)
#  code            :string(255)
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

  # == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string(255)
#  code            :string(255)
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class FeeType < ActiveRecord::Base
  BASIC_FEE_CODES = %w( BAF DAF DAH DAJ PCM SAF )

  belongs_to :fee_category

  has_many :fees, dependent: :destroy
  has_many :claims, through: :fees

  validates :fee_category, presence: true
  validates :description, presence: true, uniqueness: { case_sensitive: false, scope: :fee_category }
  validates :code, presence: true

  def self.basic
    self.by_fee_category("BASIC")
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

private

  def self.by_fee_category(category)
    self.joins(:fee_category).where('fee_categories.abbreviation = ?', category.upcase).order(:description)
  end

end
