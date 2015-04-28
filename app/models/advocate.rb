class Advocate < ActiveRecord::Base
  belongs_to :chamber
  has_one :user, as: :persona, dependent: :destroy
  has_many :claims, dependent: :destroy

  validates :user, presence: true

  accepts_nested_attributes_for :user, reject_if: :all_blank

  delegate :email, to: :user
end
