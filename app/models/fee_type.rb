class FeeType < ActiveRecord::Base
  has_many :fees, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
