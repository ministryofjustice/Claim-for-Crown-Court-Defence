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
  belongs_to :fee_category

  has_many :fees, dependent: :destroy
  has_many :claims, through: :fees

  validates :fee_category, presence: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true


  def self.basic
    self.joins(:fee_category).where('fee_categories.abbreviation = ?', "BASIC").order(:description)
  end

end
