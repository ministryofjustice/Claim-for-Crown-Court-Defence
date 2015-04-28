class Advocate < ActiveRecord::Base
  belongs_to :chamber
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :claims, dependent: :destroy

  validates :user, presence: true

  accepts_nested_attributes_for :user

  delegate :email, to: :user
end
