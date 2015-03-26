class Fee < ActiveRecord::Base
  belongs_to :fee_type

  validates :fee_type, presence: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
