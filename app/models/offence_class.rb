# == Schema Information
#
# Table name: offence_classes
#
#  id           :integer          not null, primary key
#  class_letter :string(255)
#  description  :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

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
