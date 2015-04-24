class Offence < ActiveRecord::Base
  OFFENCE_CLASSES = ('A'..'J').to_a

  has_many :claims, dependent: :nullify

  validates :description, presence: true, uniqueness: { case_sensitive: false }
  validates :offence_class, presence: true, inclusion: { in: OFFENCE_CLASSES }
end
