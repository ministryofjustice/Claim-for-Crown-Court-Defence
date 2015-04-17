class FeeType < ActiveRecord::Base
  belongs_to :fee_category

  has_many :fees, dependent: :destroy
  has_many :claims, through: :fees

  validates :fee_category, presence: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
