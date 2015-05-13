class Chamber < ActiveRecord::Base
  has_many :advocates
  has_many :claims, through: :advocates

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :account_number, presence: true, uniqueness: { case_sensitive: false }
end
