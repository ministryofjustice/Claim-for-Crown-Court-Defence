# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  unique_code      :string           default("anyoldrubbish"), not null
#

class Offence < ActiveRecord::Base
  auto_strip_attributes :description, squish: true, nullify: true

  belongs_to :offence_class
  belongs_to :fee_band
  has_many :claims, -> { active }, class_name: Claim::BaseClaim, foreign_key: :offence_id, dependent: :nullify
  has_many :offence_fee_schemes
  has_many :fee_schemes, through: :offence_fee_schemes

  validates :offence_class, presence: true, unless: :fee_band_id
  validates :fee_band, presence: true, unless: :offence_class_id
  validates :description, presence: true
  validates :unique_code, presence: true, uniqueness: true

  validate :offence_class_xor_fee_band

  default_scope { includes(:offence_class).order(:description, :offence_class_id) }

  scope :unique_name,   -> { unscoped.select(:description).distinct.order(:description) }
  scope :miscellaneous, -> { where(description: 'Miscellaneous/other') }

  def offence_class_description
    offence_class.letter_and_description
  end

  def offence_class_xor_fee_band
    return if offence_class.present? ^ fee_band.present?
    errors[:base] << 'Specify an Offence or a FeeBand, not both'
  end
end
