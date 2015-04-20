class FeeCategory < ActiveRecord::Base
  has_many :fee_types, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
