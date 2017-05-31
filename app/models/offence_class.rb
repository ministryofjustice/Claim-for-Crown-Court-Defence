# == Schema Information
#
# Table name: offence_classes
#
#  id           :integer          not null, primary key
#  class_letter :string
#  description  :string
#  created_at   :datetime
#  updated_at   :datetime
#

class OffenceClass < ActiveRecord::Base
  auto_strip_attributes :class_letter, :description, squish: true, nullify: true

  CLASS_LETTERS = ('A'..'K').to_a

  has_many :offences, dependent: :destroy

  validates :class_letter, presence: true, uniqueness: { message: 'Offence class letter must be unique' }, inclusion: { in: CLASS_LETTERS }
  validates :description, presence: true

  default_scope -> { order(class_letter: :asc) }

  def to_s
    letter_and_description
  end

  def letter_and_description
    "#{class_letter}: #{description}"
  end

  def lgfs_offence_id
    offences.miscellaneous.first.id
  end
end
