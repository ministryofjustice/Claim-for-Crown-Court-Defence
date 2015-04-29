class Chamber < ActiveRecord::Base
  has_many :advocates

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :supplier_no, presence: true, uniqueness: { case_sensitive: false }
end
