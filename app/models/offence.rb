class Offence < ActiveRecord::Base
  belongs_to :offence_class
  has_many :claims, dependent: :nullify

  validates :offence_class, presence: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
end
