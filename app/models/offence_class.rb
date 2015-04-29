class OffenceClass < ActiveRecord::Base
  CLASS_LETTERS = ('A'..'K').to_a

  has_many :offences, dependent: :destroy

  validates :class_letter, presence: true, uniqueness: true, inclusion: { in: CLASS_LETTERS }
  validates :description, presence: true

  default_scope -> { order(class_letter: :asc) }

  def to_s
    letter_and_description
  end

  def letter_and_description
    "#{class_letter}: #{description}"
  end
end
