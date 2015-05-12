class Chamber < ActiveRecord::Base
  has_many :advocates

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :account_number, presence: true, uniqueness: { case_sensitive: false }
end
