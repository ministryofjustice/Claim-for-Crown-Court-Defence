class CaseStage < ApplicationRecord
  ROLES = %w[lgfs agfs].freeze
  include Roles

  belongs_to :case_type

  delegate_missing_to :case_type

  validates :case_type_id, presence: true
  validates :unique_code, presence: { message: 'Case stage unique_code must exist' }
  validates :unique_code, uniqueness: { case_sensitve: false, message: 'Case stage unique_code must be unique' }
  validates :description, presence: { message: 'Case stage description must exist' }

  scope :chronological, -> { order(position: :asc) }
  scope :active, -> { where.not("unique_code LIKE 'OBSOLETE%'") }
end
