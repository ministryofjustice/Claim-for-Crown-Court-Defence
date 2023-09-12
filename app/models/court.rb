# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  court_type :string
#  created_at :datetime
#  updated_at :datetime
#

class Court < ApplicationRecord
  auto_strip_attributes :code, :name, squish: true, nullify: true

  COURT_TYPES = %w[crown magistrate].freeze

  has_many :claims, -> { active }, class_name: 'Claim::BaseClaim', dependent: :nullify

  validates :code, presence: true, uniqueness: { case_sensitve: false }
  validates :name, presence: true, uniqueness: { case_sensitve: false }
  validates :court_type, presence: true, inclusion: { in: COURT_TYPES }

  scope :alphabetical, -> { order(name: :asc) }
end
