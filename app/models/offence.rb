# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Offence < ActiveRecord::Base
  auto_strip_attributes :description, squish: true, nullify: true

  belongs_to :offence_class
  has_many :claims, class_name: Claim::BaseClaim, foreign_key: :offence_id, dependent: :nullify

  validates :offence_class, presence: true
  validates :description, presence: true

  default_scope { includes(:offence_class).order(:description, :offence_class_id) }

  scope :unique_name,   -> { unscoped.select(:description).distinct }
  scope :miscellaneous, -> { where(description: 'Miscellaneous/other') }

  def offence_class_description
    offence_class.letter_and_description
  end
end
